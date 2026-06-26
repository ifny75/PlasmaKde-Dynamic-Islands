import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_backgroundEnabled: bgSwitch.checked
    property alias cfg_backgroundOpacity: opacitySlider.value
    property alias cfg_borderEnabled: borderSwitch.checked
    property alias cfg_followSystemTheme: themeSwitch.checked
    property string cfg_backgroundColor: "#0b1622"
    property string cfg_accentColor: "#8d5cff"
    property string cfg_idleDotColor: "#55e36a"
    property string cfg_sharingDotColor: "#ffaa33"

    QQC2.Switch {
        id: themeSwitch
        Kirigami.FormData.label: i18n("Plasma theme:")
        text: i18n("Use the desktop theme's text and panel colors")
    }

    QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: i18n("When on, text follows your color scheme and the custom background hex is replaced by the theme background.")
    }

    Item { Kirigami.FormData.isSection: true }

    QQC2.Switch {
        id: bgSwitch
        Kirigami.FormData.label: i18n("Expanded background:")
        text: i18n("Fill the big panel (the compact capsule stays transparent)")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Background color:")
        enabled: bgSwitch.checked
        Repeater {
            model: ["#0b1622", "#000000", "#101418", "#1a1030", "#0e1f1a", "#241016"]
            ColorSwatch { swatch: modelData; selected: page.cfg_backgroundColor === modelData; onPicked: page.cfg_backgroundColor = modelData }
        }
    }

    QQC2.TextField {
        Kirigami.FormData.label: i18n("Custom background (hex):")
        enabled: bgSwitch.checked
        text: page.cfg_backgroundColor
        inputMask: "\\#HHHHHH"
        onEditingFinished: if (text.length === 7) page.cfg_backgroundColor = text
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Background opacity:")
        enabled: bgSwitch.checked
        QQC2.Slider { id: opacitySlider; from: 20; to: 100; stepSize: 1; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
        QQC2.Label { text: opacitySlider.value + "%" }
    }

    QQC2.Switch {
        id: borderSwitch
        Kirigami.FormData.label: i18n("Border:")
        enabled: bgSwitch.checked
        text: i18n("Show a subtle outline")
    }

    Item { Kirigami.FormData.isSection: true }

    RowLayout {
        Kirigami.FormData.label: i18n("Accent color:")
        Repeater {
            model: ["#8d5cff", "#2da6e8", "#55e36a", "#ff4f6f", "#ffaa33", "#ffffff"]
            ColorSwatch { swatch: modelData; selected: page.cfg_accentColor === modelData; onPicked: page.cfg_accentColor = modelData }
        }
    }

    QQC2.TextField {
        Kirigami.FormData.label: i18n("Custom accent (hex):")
        text: page.cfg_accentColor
        inputMask: "\\#HHHHHH"
        onEditingFinished: if (text.length === 7) page.cfg_accentColor = text
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Idle dot color:")
        Repeater {
            model: ["#55e36a", "#2da6e8", "#8d5cff", "#ffffff", "#ffaa33"]
            ColorSwatch { swatch: modelData; selected: page.cfg_idleDotColor === modelData; onPicked: page.cfg_idleDotColor = modelData }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Sharing dot color:")
        Repeater {
            model: ["#ffaa33", "#ff4f6f", "#ffd233", "#2da6e8", "#ffffff"]
            ColorSwatch { swatch: modelData; selected: page.cfg_sharingDotColor === modelData; onPicked: page.cfg_sharingDotColor = modelData }
        }
    }

    component ColorSwatch: Rectangle {
        property string swatch: "#ffffff"
        property bool selected: false
        signal picked()

        width: Kirigami.Units.gridUnit * 1.6
        height: width
        radius: width / 2
        color: swatch
        border.width: selected ? 3 : 1
        border.color: selected ? Kirigami.Theme.highlightColor : Qt.rgba(1, 1, 1, 0.25)

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.picked()
        }
    }
}
