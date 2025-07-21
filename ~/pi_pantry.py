import time, threading, os
import RPi.GPIO as GPIO
import firebase_admin
from firebase_admin import credentials, firestore
from picamera2 import Picamera2
from pyzbar.pyzbar import decode
import numpy as np
import tflite_runtime.interpreter as tflite
import cv2
from picamera2 import Preview
from libcamera import controls


# ── GPIO LED setup ──
LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)


# ── Firebase Admin init ──
cred = credentials.Certificate(
   os.path.expanduser("/home/brianp/Desktop/ingredii/ingredii-auth-firebase-adminsdk-fbsvc-efae5e96bc.json")
)
firebase_admin.initialize_app(cred)
db = firestore.client()


# Replace with your Auth‐UID
USER_UID = "4DWVZB729oeHXxMlY89XaxTJRCU2"


# ── TFLite stub (gesture model) ──
# Place a model at ~/gesture.tflite if desired
ml_model_path = os.path.expanduser("~/gesture.tflite")
if os.path.exists(ml_model_path):
   interpreter = tflite.Interpreter(model_path=ml_model_path)
   interpreter.allocate_tensors()
   inp_index = interpreter.get_input_details()[0]["index"]
   out_index = interpreter.get_output_details()[0]["index"]
else:
   interpreter = None


#
#
# ── Camera setup ──
picam2 = Picamera2()
picam2.start_preview(Preview.QTGL)
# Enable continuous auto-focus mode
camera_config = picam2.create_preview_configuration()
picam2.configure(camera_config)
picam2.start()
picam2.set_controls({"AfMode": controls.AfModeEnum.Continuous})


mode_add = True           # True = add, False = remove
last_barcode = None
cover_threshold = 25      # luma threshold


def run_ml_gesture(frame: np.ndarray) -> bool:
   """Stub: returns True if gesture says 'toggle mode'."""
   if interpreter is None:
       return False
   # Preprocess frame to model input (stub—you must match your model!)
   resized = np.array(frame, dtype=np.float32)
   resized = np.resize(resized, (224, 224, resized.shape[2] if resized.ndim == 3 else 1))
   resized = np.expand_dims(resized / 255.0, 0).astype(np.float32)
   interpreter.set_tensor(inp_index, resized)
   interpreter.invoke()
   scores = interpreter.get_tensor(out_index)[0]
   # Suppose index 1 = “toggle” gesture
   return scores[1] > 0.7


def update_firestore(barcode: str):
   """Increment or decrement Firestore pantry doc."""
   doc = db.collection("pantries").document(USER_UID)
   # Use a transaction for atomicity
   @firestore.transactional
   def txn(t):
       snap = doc.get(transaction=t)
       data = snap.to_dict() or {}
       items = data.get("items", [])  # list of dicts
       # find existing
       for i, itm in enumerate(items):
           if itm.get("barcode") == barcode:
               # decrement or increment
               if mode_add:
                   itm["quantity"] = itm.get("quantity",0) + 1
               else:
                   if itm.get("quantity",0) > 1:
                       itm["quantity"] -= 1
                   else:
                       items.pop(i)
               break
       else:
           # not found & add-mode → create new
           if mode_add:
               items.append({
                 "barcode": barcode,
                 "name":    barcode,
                 "imageName":"photo",
                 "quantity": 1,
                 "expiryDate": time.time(),
                 "isStaple": False
               })
       t.set(doc, {"items": items}, merge=True)


   transaction = db.transaction()
   txn(transaction)


def scan_loop():
   global mode_add, last_barcode
   while True:
       frame = picam2.capture_array()
       # ① brightness check
       y_plane = frame[:,:,0] if frame.ndim==3 else frame
       avg_luma = int(np.mean(y_plane))
       covered = avg_luma < cover_threshold
       if covered != (not mode_add):
           mode_add = not covered
           GPIO.output(LED_PIN, GPIO.HIGH if mode_add else GPIO.LOW)


       # ② optional ML gesture
       if run_ml_gesture(frame):
           mode_add = not mode_add
           GPIO.output(LED_PIN, GPIO.HIGH if mode_add else GPIO.LOW)
           time.sleep(0.5)  # debounce


       # ③ barcode decode and draw rectangles for preview
       for b in decode(frame):
           code = b.data.decode()
           (x, y, w, h) = b.rect
           color = (0, 255, 0) if mode_add else (0, 0, 255)
           cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
           cv2.putText(frame, code, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
           if code != last_barcode:
               last_barcode = code
               print("[SCAN]", code, "→", "ADD" if mode_add else "REMOVE")
               update_firestore(code)


       # Show OpenCV window with overlay
       cv2.imshow("Camera Preview", frame)
       if cv2.waitKey(1) & 0xFF == ord('q'):
           break


       time.sleep(0.1)


   cv2.destroyAllWindows()


if __name__=="__main__":
   print("Starting Pi‐Pantry Scanner…")
   # LED initially on for “add” mode
   GPIO.output(LED_PIN, GPIO.HIGH)
   scan_loop()

