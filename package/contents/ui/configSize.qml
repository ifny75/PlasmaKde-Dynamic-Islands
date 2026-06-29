import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    property alias cfg_expandedWidthMusic: musicWidthSpin.value
    property alias cfg_expandedWidthNotification: notifWidthSpin.value
    property alias cfg_expandedWidthStatus: statusWidthSpin.value
    property alias cfg_expandedHeight: heightSpin.value
    property alias cfg_cornerRadius: radiusSpin.value

    QQC2.SpinBox { id: musicWidthSpin;  Kirigami.FormData.label: Tr.t("Music panel width:");        from: 280; to: 680; stepSize: 10 }
    QQC2.SpinBox { id: notifWidthSpin;  Kirigami.FormData.label: Tr.t("Notification panel width:"); from: 260; to: 640; stepSize: 10 }
    QQC2.SpinBox { id: statusWidthSpin; Kirigami.FormData.label: Tr.t("Status panel width:");       from: 240; to: 600; stepSize: 10 }
    QQC2.SpinBox { id: heightSpin;      Kirigami.FormData.label: Tr.t("Expanded panel height:");    from: 64;  to: 160; stepSize: 2 }
    QQC2.SpinBox { id: radiusSpin;      Kirigami.FormData.label: Tr.t("Corner radius:");            from: 6;   to: 28;  stepSize: 1 }
}
