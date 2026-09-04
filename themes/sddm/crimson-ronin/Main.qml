import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root
    width: 1920
    height: 1080
    opacity: 0
    color: "#050506"

    property color blade: "#F5F2EF"
    property color muted: "#90898B"
    property color graphite: "#24242B"
    property color darkRed: "#35070B"
    property color crimson: "#A70E18"
    property color active: "#E21A28"
    property bool loginFailed: false

    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 620
        easing.type: Easing.OutCubic
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#F0050506" }
            GradientStop { position: 0.46; color: "#A8050506" }
            GradientStop { position: 1.0; color: "#60050506" }
        }
    }

    Rectangle {
        id: glass
        width: 420
        height: 590
        scale: 0.985
        anchors.left: parent.left
        anchors.leftMargin: Math.max(96, root.width * 0.105)
        anchors.verticalCenter: parent.verticalCenter
        radius: 20
        color: "#DF08080B"
        border.width: 1
        border.color: "#7024242B"

        NumberAnimation on scale {
            from: 0.985
            to: 1
            duration: 460
            easing.type: Easing.OutCubic
        }

        Rectangle {
            width: 2
            height: parent.height - 54
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            radius: 1
            color: root.active
            opacity: 0.76
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 38
            spacing: 10

            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                source: "assets/ronin-mark.svg"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: root.active
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.letterSpacing: 2.5
                text: "CRIMSON RONIN"
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 42
                Layout.preferredHeight: 1
                Layout.bottomMargin: 3
                color: root.active
                opacity: 0.74
            }

            Text {
                id: clock
                Layout.alignment: Qt.AlignHCenter
                color: root.blade
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 50
                font.weight: Font.Medium
                font.letterSpacing: 0.8
                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 12
                color: root.muted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.letterSpacing: 0.6
                text: Qt.formatDate(new Date(), "dddd").toUpperCase()
                      + "   ·   " + Qt.formatDate(new Date(), "dd MMMM").toUpperCase()
            }

            ComboBox {
                id: user
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "name"
                valueRole: "name"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                background: Rectangle {
                    radius: 11
                    color: user.activeFocus ? "#F517171D" : "#F2111116"
                    border.width: 1
                    border.color: user.activeFocus ? root.crimson : root.graphite
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: user.activeFocus ? parent.width - 22 : 42
                        height: 2
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: user.activeFocus ? root.active : root.darkRed
                        Behavior on width {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                contentItem: Text {
                    leftPadding: 15
                    rightPadding: 28
                    text: user.displayText
                    color: root.blade
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font: user.font
                }
            }

            TextField {
                id: password
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                echoMode: TextInput.Password
                placeholderText: "PASSWORD"
                placeholderTextColor: root.muted
                color: root.blade
                selectionColor: root.darkRed
                selectedTextColor: root.blade
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                leftPadding: 15
                rightPadding: 15
                focus: true

                background: Rectangle {
                    radius: 11
                    color: password.activeFocus ? "#F517171D" : "#F2111116"
                    border.width: root.loginFailed ? 2 : 1
                    border.color: root.loginFailed ? "#FF2938"
                                                    : (password.activeFocus ? root.active : root.graphite)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: password.activeFocus ? parent.width - 22 : 42
                        height: 2
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.loginFailed ? "#FF2938"
                                                : (password.activeFocus ? root.active : root.darkRed)
                        Behavior on width {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                onTextChanged: {
                    if (root.loginFailed) {
                        root.loginFailed = false
                        status.text = ""
                    }
                }
                onAccepted: sddm.login(user.currentValue, text, session.currentIndex)
            }

            Text {
                id: status
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 14
                color: "#FF2938"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
                font.letterSpacing: 1.4
                text: ""
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                text: "UNLOCK"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.letterSpacing: 1.5
                onClicked: sddm.login(user.currentValue, password.text, session.currentIndex)

                background: Rectangle {
                    radius: 10
                    color: parent.down ? root.crimson
                                       : (parent.hovered ? "#57090E" : root.darkRed)
                    border.width: 1
                    border.color: root.active
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                contentItem: Text {
                    text: parent.text
                    color: root.blade
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }

            Item { Layout.fillHeight: true }

            ComboBox {
                id: session
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 190
                Layout.preferredHeight: 32
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10

                background: Rectangle {
                    radius: 8
                    color: "#8A111116"
                    border.width: 1
                    border.color: root.graphite
                }

                contentItem: Text {
                    leftPadding: 12
                    rightPadding: 24
                    text: session.displayText
                    color: root.muted
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font: session.font
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.graphite
                opacity: 0.68
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    Layout.fillWidth: true
                    text: "SUSPEND"
                    flat: true
                    onClicked: sddm.suspend()
                    contentItem: Text {
                        text: parent.text
                        color: parent.hovered ? root.blade : root.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "RESTART"
                    flat: true
                    onClicked: sddm.reboot()
                    contentItem: Text {
                        text: parent.text
                        color: parent.hovered ? root.blade : root.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "POWER"
                    flat: true
                    onClicked: sddm.powerOff()
                    contentItem: Text {
                        text: parent.text
                        color: parent.hovered ? root.active : root.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.loginFailed = true
            status.text = "AUTHENTICATION FAILED"
            password.selectAll()
            password.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.loginFailed = false
            status.text = ""
        }
    }
}
