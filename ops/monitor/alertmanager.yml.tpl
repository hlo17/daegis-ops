route:
  receiver: brief
  group_by: ['alertname','agent']
  group_wait: 10s
  group_interval: 2m
  repeat_interval: 12h
  routes:
    - receiver: recovery
      matchers: [ 'severity = "critical"' ]
    - receiver: roundtable
      matchers: [ 'audience = "roundtable"' ]

receivers:
  - name: brief
    slack_configs:
      - api_url: '${SLACK_BRIEF_WEBHOOK}'
        channel: '#daegis-brief'
        title: '{{ .CommonAnnotations.summary }}'
        text: >-
          {{ range .Alerts -}}
          *{{ .Labels.alertname }}* (agent={{ .Labels.agent }}, severity={{ .Labels.severity | default "n/a" }})
          {{ .Annotations.description }}
          {{- "\n" -}}
          {{ end }}

  - name: recovery
    slack_configs:
      - api_url: '${SLACK_RECOVERY_WEBHOOK}'
        channel: '#daegis-recovery'
        title: ':rotating_light: {{ .CommonAnnotations.summary }}'
        text: >-
          {{ range .Alerts -}}
          *{{ .Labels.alertname }}* (agent={{ .Labels.agent }})
          {{ .Annotations.description }}
          {{- "\n" -}}
          {{ end }}

  - name: roundtable
    slack_configs:
      - api_url: '${SLACK_ROUNDTABLE_WEBHOOK}'
        channel: '#daegis-roundtable'
        title: ':speech_balloon: {{ .CommonAnnotations.summary }}'
        text: >-
          {{ range .Alerts -}}
          *{{ .Labels.alertname }}* (agent={{ .Labels.agent }})
          {{ .Annotations.description }}
          {{- "\n" -}}
          {{ end }}
