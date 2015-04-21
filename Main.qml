import QtQuick 2.0
import Ubuntu.Components 1.1
import QtSensors 5.0

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "level.mhall119"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    height: units.gu(100)
    width: units.gu(100)

    Accelerometer {
        id: accel
        active: true

        onReadingChanged: {
            var x = accel.reading.x;
            var y = accel.reading.y;
            var rotate = 0
            if (x > 0) {
                if (y > 0) {
                    rotate = 90 - (y*10);
                } else {
                    rotate = (-y*10) + 90;
                }
            } else {
                if (y > 0) {
                    rotate = -90 + (y*10);
                } else {
                    rotate = -90 + (-y*-10);
                }
            }
            container.rotation = rotate

        }
    }

    Rectangle {
        id: container
        //rotation: getRotation()
        anchors.centerIn: parent
        height: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        width: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        color: "white"

        Behavior on rotation {
            SmoothedAnimation { velocity: 100; }
        }

        Rectangle {
            id: level
            height: parent.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2
            color: "red"
        }

        Label {
            id: degrees
            anchors.bottom: level.top
            anchors.bottomMargin: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(container.rotation) + "&deg;"
            textFormat: Text.RichText
        }
    }

}

