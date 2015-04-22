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

        property real smoothing: 0.03
        property real ax
        property real ay
        property real az
        // Angle of acceleration vector in X-Y plane
        property real theta
        // Angle of acceleration out of X-Y plane
        property real phi

        onReadingChanged: {
            ax = smoothing * reading.x + (1 - smoothing) * ax
            ay = smoothing * reading.y + (1 - smoothing) * ay
            az = smoothing * reading.z + (1 - smoothing) * az

            theta = Math.atan2(ay, ax) * 180 / Math.PI
            phi = Math.atan2(az, Math.sqrt(ax*ax + ay*ay)) * 180 / Math.PI
        }
    }

    Rectangle {
        id: vertLevel
        visible: accel.phi > -45 && accel.phi < 45
        rotation: 90 - accel.theta
        anchors.centerIn: parent
        height: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        width: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        color: "white"

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
            text: Math.round(vertLevel.rotation + 360) % 360 + "&deg;"
            textFormat: Text.RichText
        }
    }

    Rectangle {
        id: horizLevel
        visible: !vertLevel.visible
        anchors.fill: parent
        color: "white"

        function distForAngle(angle) {
            return width / 2 * Math.sin(angle * Math.PI / 90)
        }

        Repeater {
            model: [40, 25, 15, 10, 5, 1]
            Rectangle {
                anchors.centerIn: parent
                width: 2 * horizLevel.distForAngle(modelData)
                height: width
                radius: width/2
                border.color: "black"
                border.width: units.dp(2)
            }
        }

        Rectangle {
            width: units.gu(3)
            height: width
            radius: width/2
            color: "red"
            x: (horizLevel.width - width) / 2 + Math.cos(accel.theta * Math.PI / 180) * horizLevel.distForAngle(90 - Math.abs(accel.phi))
            y: (horizLevel.height - height) / 2 - Math.sin(accel.theta * Math.PI / 180) * horizLevel.distForAngle(90 - Math.abs(accel.phi))
        }
    }
}

