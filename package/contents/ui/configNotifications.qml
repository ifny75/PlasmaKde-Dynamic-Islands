import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_enableNotifications: notifSwitch.checked
    property alias cfg_notificationBodyLines: bodyLinesSpin.value

    QQC2.Switch {
        id: notifSwitch
        Kirigami.FormData.label: i18n("Notifications:")
        text: i18n("Show incoming notifications")
    }

    QQC2.SpinBox {
        id: bodyLinesSpin
        Kirigami.FormData.label: i18n("Body lines:")
        enabled: notifSwitch.checked
        from: 1; to: 4; stepSize: 1
    }
}
