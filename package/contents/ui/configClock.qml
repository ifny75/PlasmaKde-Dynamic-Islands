import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "Translator.js" as Tr

Kirigami.FormLayout {
    property alias cfg_use24HourClock: clockSwitch.checked
    property alias cfg_showSeconds: secondsSwitch.checked
    property alias cfg_showDate: dateSwitch.checked

    QQC2.Switch { id: clockSwitch;   Kirigami.FormData.label: Tr.t("Format:");  text: Tr.t("Use 24-hour clock") }
    QQC2.Switch { id: secondsSwitch; Kirigami.FormData.label: Tr.t("Seconds:"); text: Tr.t("Show seconds") }
    QQC2.Switch { id: dateSwitch;    Kirigami.FormData.label: Tr.t("Date:");    text: Tr.t("Show day and date") }
}
