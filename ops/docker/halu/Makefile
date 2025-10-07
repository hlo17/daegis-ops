.PHONY: broker.fix broker.smoke relay.up relay.logs

broker.fix:
	@printf '%s\n' \
		"persistence true" \
		"persistence_location /var/lib/mosquitto/" \
		"include_dir /etc/mosquitto/conf.d" \
	| sudo tee /etc/mosquitto/mosquitto.conf >/dev/null

	@printf '%s\n' \
		"per_listener_settings true" \
		"autosave_interval 60" \
	| sudo tee /etc/mosquitto/conf.d/00-base.conf >/dev/null

	@printf '%s\n' \
		"listener 1883 0.0.0.0" \
		"allow_anonymous false" \
		"password_file /etc/mosquitto/passwd" \
		"acl_file      /etc/mosquitto/acl" \
	| sudo tee /etc/mosquitto/conf.d/10-daegis-auth.conf >/dev/null

	@sudo systemctl restart mosquitto

broker.smoke:
	@mosquitto_pub -h 127.0.0.1 -u f -P 'TestPw-123' -t daegis/test/ping -m ok -r
	@mosquitto_sub -h 127.0.0.1 -u f -P 'TestPw-123' -t daegis/test/ping -C 1 -W 3 -v

relay.up:
	-@docker rm -f halu-relay
	@docker run -d --name halu-relay --restart unless-stopped \
	  -e MQTT_HOST=192.168.0.183 -e MQTT_PORT=1883 \
	  -e MQTT_USER=f -e MQTT_PASS=TestPw-123 \
	  -e HALU_TOPIC_IN=daegis/halu/train/inbox \
	  -e HALU_TOPIC_OUT=daegis/halu/train/outbox \
	  -e HALU_TOPIC_METRICS=daegis/halu/metrics \
	  halu-halu

relay.logs:
	@docker logs --tail=100 -f halu-relay
