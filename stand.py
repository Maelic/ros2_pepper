import qi
import argparse
import sys
import time
import almath

def main(session):
    """
    This example uses the setAngles method and setStiffnesses method
    in order to control joints.
    """
    # Get the service ALMotion.



    posture_service = session.service("ALRobotPosture")

    posture_service.goToPosture("StandInit", 1.0)

    motion_service  = session.service("ALMotion")

    motion_service.setStiffnesses("Head", 1.0)

    life_service = session.service("ALAutonomousLife")
    life_service.setAutonomousAbilityEnabled("BasicAwareness", False)

    # Simple command for the HeadYaw joint at 10% max speed
    names            = "HeadYaw"
    angles           = 0.0
    fractionMaxSpeed = 0.3
    motion_service.setAngles(names,angles,fractionMaxSpeed)

    names            = "HeadPitch"
    angles           = 0.2
    fractionMaxSpeed = 0.3
    motion_service.setAngles(names,angles,fractionMaxSpeed)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", type=str, default="127.0.0.1",
                        help="Robot IP address. On robot or Local Naoqi: use '127.0.0.1'.")
    parser.add_argument("--port", type=int, default=9559,
                        help="Naoqi port number")

    args = parser.parse_args()
    session = qi.Session()
    try:
        session.connect("tcp://" + args.ip + ":" + str(args.port))
    except RuntimeError:
        print ("Can't connect to Naoqi at ip \"" + args.ip + "\" on port " + str(args.port) +".\n"
               "Please check your script arguments. Run with -h option for help.")
        sys.exit(1)
    main(session)

