import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_enableMedia: mediaSwitch.checked
    property alias cfg_enableKeyboard: keyboardSwitch.checked
    property alias cfg_enableDownloads: downloadsSwitch.checked
    property alias cfg_enableScreenSharing: sharingSwitch.checked
    property alias cfg_ideBuildEnabled: ideSwitch.checked

    QQC2.Switch { id: mediaSwitch;     Kirigami.FormData.label: i18n("Media:");          text: i18n("Now playing / MPRIS") }
    QQC2.Switch { id: keyboardSwitch;  Kirigami.FormData.label: i18n("Keyboard layout:"); text: i18n("Announce layout changes") }
    QQC2.Switch { id: downloadsSwitch; Kirigami.FormData.label: i18n("Downloads:");      text: i18n("Show active jobs / progress") }
    QQC2.Switch { id: sharingSwitch;   Kirigami.FormData.label: i18n("Screen sharing:"); text: i18n("Show capture / presentation state") }
    QQC2.Switch { id: ideSwitch;       Kirigami.FormData.label: i18n("IntelliJ IDEA:");  text: i18n("Show build results (e.g. JAR build succeeded)") }
}
