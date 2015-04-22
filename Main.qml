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

        // Angle of acceleration vector in X-Y plane
        property real theta

        onReadingChanged: {
            theta = Math.atan2(accel.reading.y, accel.reading.x) * 180 / Math.PI
        }
    }

    Rectangle {
        id: container
        rotation: 90 - accel.theta
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
            // The mod function is broken for negative numbers
            text: Math.round(container.rotation + 360) % 360 + "&deg;"
            textFormat: Text.RichText
        }
    }

}

