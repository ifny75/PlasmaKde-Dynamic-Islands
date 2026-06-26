import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_use24HourClock: clockSwitch.checked
    property alias cfg_showSeconds: secondsSwitch.checked
    property alias cfg_showDate: dateSwitch.checked

    QQC2.Switch { id: clockSwitch;   Kirigami.FormData.label: i18n("Format:");  text: i18n("Use 24-hour clock") }
    QQC2.Switch { id: secondsSwitch; Kirigami.FormData.label: i18n("Seconds:"); text: i18n("Show seconds") }
    QQC2.Switch { id: dateSwitch;    Kirigami.FormData.label: i18n("Date:");    text: i18n("Show day and date") }
}
