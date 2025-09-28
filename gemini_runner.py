import paho.mqtt.client as mqtt
import time
import json

# --- 設定項目 ---
BROKER_ADDRESS = "localhost"
PORT = 1883
CLIENT_NAME = "gemini_runner"

SUBSCRIBE_TOPIC = "daegis/gemini/command"
PUBLISH_TOPIC = "daegis/gemini/status"

# --- MQTTコールバック関数 ---

def on_connect(client, userdata, flags, rc, properties=None):
    """ブローカーに接続したときの処理"""
    if rc == 0:
        print("MQTTブローカーに接続しました。")
        client.subscribe(SUBSCRIBE_TOPIC)
        print(f"トピック '{SUBSCRIBE_TOPIC}' の購読を開始しました。")
    else:
        print(f"MQTTブローカーへの接続に失敗しました。リターンコード: {rc}")

def on_message(client, userdata, msg):
    """メッセージを受信したときの処理"""
    print(f"メッセージを受信しました。 トピック: {msg.topic}")
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
        print(f"内容: {payload}")
        if "command" in payload and payload["command"] == "get_status":
            print("ステータス要求を受け取りました。")
            response = {"status": "OK", "runner": CLIENT_NAME}
            client.publish(PUBLISH_TOPIC, json.dumps(response))
            print(f"トピック '{PUBLISH_TOPIC}' に応答を送信しました。")
    except json.JSONDecodeError:
        print(f"エラー: JSON形式ではないメッセージを受信しました: {msg.payload.decode('utf-8')}")
    except Exception as e:
        print(f"メッセージ処理中にエラーが発生しました: {e}")

# --- メイン処理 ---

if __name__ == '__main__':
    # MQTTクライアントの初期化 (v2.0 APIを指定)
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, CLIENT_NAME)

    client.on_connect = on_connect
    client.on_message = on_message

    try:
        client.connect(BROKER_ADDRESS, PORT, 60)
        client.publish(PUBLISH_TOPIC, json.dumps({"status": "runner_started"}))
        print("メッセージ待機中... (Ctrl+Cで終了)")
        client.loop_forever()
    except KeyboardInterrupt:
        print("\nプログラムを終了します。")
    except Exception as e:
        print(f"エラーが発生したためプログラムを終了します: {e}")
    finally:
        client.disconnect()
        print("MQTTブローカーから切断しました。")
