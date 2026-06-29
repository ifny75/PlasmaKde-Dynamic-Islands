import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    id: page

    property string cfg_compactOrder: "content-time-fps"
    property alias cfg_moduleSeparators: separatorsSwitch.checked
    property alias cfg_popupGap: gapSpin.value

    QQC2.ComboBox {
        id: orderCombo
        Kirigami.FormData.label: Tr.t("Compact order:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: Tr.t("Content · Time · FPS"), value: "content-time-fps" },
            { text: Tr.t("Time · Content · FPS"), value: "time-content-fps" },
            { text: Tr.t("Content · FPS · Time"), value: "content-fps-time" },
            { text: Tr.t("FPS · Content · Time"), value: "fps-content-time" },
            { text: Tr.t("Time · FPS · Content"), value: "time-fps-content" },
            { text: Tr.t("FPS · Time · Content"), value: "fps-time-content" }
        ]
        onActivated: page.cfg_compactOrder = currentValue
        Component.onCompleted: currentIndex = indexOfValue(page.cfg_compactOrder)
    }

    QQC2.Switch {
        id: separatorsSwitch
        Kirigami.FormData.label: Tr.t("Separators:")
        text: Tr.t("Show “/” dividers between modules")
    }

    QQC2.Label {
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: Tr.t("“Content” is the active item — music, language, notification, download or status. Time and the FPS counter can be placed before or after it.")
    }

    Item { Kirigami.FormData.isSection: true }

    QQC2.SpinBox {
        id: gapSpin
        Kirigami.FormData.label: Tr.t("Distance from panel:")
        from: 0; to: 120; stepSize: 2
    }

    QQC2.Label {
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: Tr.t("Gap between the small capsule and the big expanded panel. Increase it if the panel appears too close to or overlapping the capsule.")
    }
}
