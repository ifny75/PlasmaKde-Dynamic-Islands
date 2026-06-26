import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Size & Shape")
        icon: "transform-scale"
        source: "configSize.qml"
    }
    ConfigCategory {
        name: i18n("Layout")
        icon: "view-split-left-right"
        source: "configLayout.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Clock")
        icon: "preferences-system-time"
        source: "configClock.qml"
    }
    ConfigCategory {
        name: i18n("Notifications")
        icon: "preferences-desktop-notification-bell"
        source: "configNotifications.qml"
    }
    ConfigCategory {
        name: i18n("Modules")
        icon: "view-visible"
        source: "configFeatures.qml"
    }
    ConfigCategory {
        name: i18n("System & FPS")
        icon: "utilities-system-monitor"
        source: "configMonitor.qml"
    }
    ConfigCategory {
        name: i18n("Animation")
        icon: "preferences-desktop-effects"
        source: "configAnimation.qml"
    }
}
