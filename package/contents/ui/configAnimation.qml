import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_animationsEnabled: animationsSwitch.checked
    property alias cfg_animationSpeed: speedSlider.value

    QQC2.Switch {
        id: animationsSwitch
        Kirigami.FormData.label: i18n("Animations:")
        text: i18n("Enable transitions and pulses")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Animation speed:")
        enabled: animationsSwitch.checked
        QQC2.Slider { id: speedSlider; from: 40; to: 200; stepSize: 10; Layout.preferredWidth: Kirigami.Units.gridUnit * 10 }
        QQC2.Label { text: speedSlider.value + "%" }
    }
}
