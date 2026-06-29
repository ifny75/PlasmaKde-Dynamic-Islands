import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    property alias cfg_enableNotifications: notifSwitch.checked
    property alias cfg_notificationBodyLines: bodyLinesSpin.value

    QQC2.Switch {
        id: notifSwitch
        Kirigami.FormData.label: Tr.t("Notifications:")
        text: Tr.t("Show incoming notifications")
    }

    QQC2.SpinBox {
        id: bodyLinesSpin
        Kirigami.FormData.label: Tr.t("Body lines:")
        enabled: notifSwitch.checked
        from: 1; to: 4; stepSize: 1
    }
}
