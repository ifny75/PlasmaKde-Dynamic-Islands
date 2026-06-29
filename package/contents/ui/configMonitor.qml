import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    id: page

    property alias cfg_enableSysMonitor: sysMonSwitch.checked
    property alias cfg_sysMonitorInterval: sysIntervalSpin.value
    property alias cfg_showCpuStat: cpuStatSwitch.checked
    property alias cfg_showRamStat: ramStatSwitch.checked
    property alias cfg_showTempStat: tempStatSwitch.checked
    property alias cfg_showFps: fpsSwitch.checked
    property string cfg_fpsStyle: "accent"

    QQC2.Switch {
        id: sysMonSwitch
        Kirigami.FormData.label: Tr.t("System stats:")
        text: Tr.t("Alternate the idle clock with system usage")
    }

    QQC2.Switch {
        id: cpuStatSwitch
        Kirigami.FormData.label: Tr.t("Show:")
        enabled: sysMonSwitch.checked
        text: Tr.t("CPU usage")
    }

    QQC2.Switch {
        id: ramStatSwitch
        enabled: sysMonSwitch.checked
        text: Tr.t("RAM usage")
    }

    QQC2.Switch {
        id: tempStatSwitch
        enabled: sysMonSwitch.checked
        text: Tr.t("CPU temperature")
    }

    QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: Tr.t("Temperature is hidden automatically if your hardware doesn't expose a CPU sensor.")
    }

    RowLayout {
        Kirigami.FormData.label: Tr.t("Switch every:")
        enabled: sysMonSwitch.checked
        QQC2.SpinBox { id: sysIntervalSpin; from: 3; to: 30; stepSize: 1 }
        QQC2.Label { text: Tr.t("sec") }
    }

    Item { Kirigami.FormData.isSection: true }

    QQC2.Switch {
        id: fpsSwitch
        Kirigami.FormData.label: Tr.t("FPS counter:")
        text: Tr.t("Permanently show frames-per-second next to the clock")
    }

    QQC2.ComboBox {
        id: fpsStyleCombo
        Kirigami.FormData.label: Tr.t("FPS style:")
        enabled: fpsSwitch.checked
        textRole: "text"
        valueRole: "value"
        model: [
            { text: Tr.t("Accent badge (e.g. 60 fps)"), value: "accent" },
            { text: Tr.t("Match clock font (e.g. 60)"), value: "plain" }
        ]
        onActivated: page.cfg_fpsStyle = currentValue
        Component.onCompleted: currentIndex = indexOfValue(page.cfg_fpsStyle)
    }

    QQC2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        font: Kirigami.Theme.smallFont
        text: Tr.t("Note: the FPS meter keeps the widget repainting continuously, which uses a little more power.")
    }
}
