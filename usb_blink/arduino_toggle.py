import serial
import time

def send_command(ser, command):
    ser.write(command.encode())
    time.sleep(0.1)  # Give Arduino time to process

def main():
    try:
        ser = serial.Serial('COM3', 9600)  # Replace 'COM3' with your Arduino's serial port
        print("Serial port opened. Type '1' to start blinking, '0' to stop, or 'q' to quit.")

        while True:
            user_input = input("> ")
            if user_input == '1' or user_input == '0':
                send_command(ser, user_input)
            elif user_input == 'q':
                break
            else:
                print("Invalid input. Use '1', '0', or 'q'.")

    except serial.SerialException as e:
        print(f"Error: {e}")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Serial port closed.")

if __name__ == "__main__":
    main()
