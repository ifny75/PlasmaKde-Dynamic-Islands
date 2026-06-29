import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    property alias cfg_enableMedia: mediaSwitch.checked
    property alias cfg_enableKeyboard: keyboardSwitch.checked
    property alias cfg_enableDownloads: downloadsSwitch.checked
    property alias cfg_enableScreenSharing: sharingSwitch.checked
    property alias cfg_ideBuildEnabled: ideSwitch.checked

    QQC2.Switch { id: mediaSwitch;     Kirigami.FormData.label: Tr.t("Media:");          text: Tr.t("Now playing / MPRIS") }
    QQC2.Switch { id: keyboardSwitch;  Kirigami.FormData.label: Tr.t("Keyboard layout:"); text: Tr.t("Announce layout changes") }
    QQC2.Switch { id: downloadsSwitch; Kirigami.FormData.label: Tr.t("Downloads:");      text: Tr.t("Show active jobs / progress") }
    QQC2.Switch { id: sharingSwitch;   Kirigami.FormData.label: Tr.t("Screen sharing:"); text: Tr.t("Show capture / presentation state") }
    QQC2.Switch { id: ideSwitch;       Kirigami.FormData.label: Tr.t("IntelliJ IDEA:");  text: Tr.t("Show build results (e.g. JAR build succeeded)") }
}
