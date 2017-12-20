import QtQuick 2.4
import Ubuntu.Components 1.3
import QtSensors 5.0

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "level.ubports"

    height: units.gu(100)
    width: units.gu(100)

    backgroundColor: UbuntuColors.jet //"#133552"

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

    property bool radialBubble: false

    Rectangle {
        id: vertLevel
        rotation: 90 - accel.theta
        anchors.centerIn: parent
        height: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        width: Math.sqrt((parent.height*parent.height) + (parent.width*parent.width))
        color: UbuntuColors.jet //"#133552"
        visible: !radialBubble

        Rectangle {
            id: level
            height: parent.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2
            color: "#d1c20e"
        }

        Label {
            id: degrees
            anchors.bottom: level.top
            anchors.bottomMargin: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            // The mod function is broken for negative numbers
            text: Math.round(vertLevel.rotation + 360) % 360 + "&deg;"
            textFormat: Text.RichText
            font.pixelSize: units.dp(48)
            font.weight: Font.DemiBold
            color: "#d1c20e"
        }
    }

    Rectangle {
        id: horizLevel
        anchors.fill: parent
        color: UbuntuColors.jet //"#133552"
        visible: radialBubble

        function distForAngle(angle) {
            return width / 2 * Math.sin(angle * Math.PI / 90)
        }

        Rectangle {
            width: units.gu(3)
            height: width
            radius: width/2
            color: "#d1c20e"
            x: (horizLevel.width - width) / 2 + Math.cos(accel.theta * Math.PI / 180) * horizLevel.distForAngle(90 - Math.abs(accel.phi))
            y: (horizLevel.height - height) / 2 - Math.sin(accel.theta * Math.PI / 180) * horizLevel.distForAngle(90 - Math.abs(accel.phi))
        }

        Repeater {
            model: [40, 25, 15, 10, 5, 1]
            Rectangle {
                anchors.centerIn: parent
                width: 2 * horizLevel.distForAngle(modelData)
                height: width
                radius: width/2
                border.color: "#d1c20e"
                border.width: units.dp(1)
                color: "transparent"

                Label {
                    x: 0.85 * parent.width
                    y: 0.85 * parent.height
                    text: modelData + "&deg;"
                    textFormat: Text.RichText
                    color: "#d1c20e"
                }
            }
        }
    }

    AbstractButton {
        anchors.fill: parent
        onClicked: radialBubble = !radialBubble
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { bottom: parent.bottom; bottomMargin: units.dp(4) }
        text: i18n.tr("Tap anywhere to switch mode")
        textSize: Label.Large
        color: radialBubble ? "#d1c20e" : UbuntuColors.jet
    }
}

