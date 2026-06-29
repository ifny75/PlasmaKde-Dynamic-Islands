import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    property alias cfg_animationsEnabled: animationsSwitch.checked
    property alias cfg_animationSpeed: speedSlider.value

    QQC2.Switch {
        id: animationsSwitch
        Kirigami.FormData.label: Tr.t("Animations:")
        text: Tr.t("Enable transitions and pulses")
    }

    RowLayout {
        Kirigami.FormData.label: Tr.t("Animation speed:")
        enabled: animationsSwitch.checked
        QQC2.Slider { id: speedSlider; from: 40; to: 200; stepSize: 10; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
        QQC2.Label { text: speedSlider.value + "%" }
    }
}
