import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris
import org.kde.plasma.workspace.components as WorkspaceComponents
import "Translator.js" as Tr

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Native hover tooltip showing the full text the compact capsule elides.
    toolTipMainText: {
        if (popupOpen) return ""
        if (showMedia) return mediaTitle || Tr.t("Music")
        if (activeMode === 2) return notificationTitle || Tr.t("Notification")
        if (compactTitle.length > 0) return compactTitle
        return timeText
    }
    toolTipSubText: {
        if (popupOpen) return ""
        if (showMedia) return mediaArtist || mediaIdentity || ""
        if (activeMode === 2) return notificationBody || notificationApp || ""
        return ""
    }

    readonly property int compactMinWidth: 82
    readonly property int compactMaxWidth: 560
    readonly property int compactSidePadding: 18
    readonly property int compactTextMaxWidth: 420
    readonly property int compactTextWidth: Math.min(compactTextMaxWidth, Math.ceil(compactTitleMetrics.width))
    readonly property int compactLeadingWidth: showGreenDot ? 10 : activeMode === 0 ? (sharingScreen ? 86 : 68) : 24
    readonly property int compactTrailingWidth: (activeMode === 2 && unreadCount > 0 ? 22 : Math.ceil(compactTimeMetrics.width)) + (showFps ? 48 : 0)
    readonly property int compactGapWidth: showGreenDot ? 8 : activeMode === 0 ? 24 : 16
    readonly property int compactSeparatorsWidth: moduleSeparators ? Math.max(0, compactVisibleList.length - 1) * 16 : 0
    readonly property int compactContentWidth: compactLeadingWidth + compactTextWidth + compactTrailingWidth + compactGapWidth + compactSeparatorsWidth
    readonly property int compactWidth: Math.max(compactMinWidth, Math.min(compactMaxWidth, compactContentWidth + compactSidePadding * 2))
    readonly property int expandedWidth: activeMode === 0 ? Plasmoid.configuration.expandedWidthMusic
        : activeMode === 2 ? Plasmoid.configuration.expandedWidthNotification
        : Plasmoid.configuration.expandedWidthStatus
    readonly property int compactHeight: 32
    readonly property int expandedHeight: Plasmoid.configuration.expandedHeight
    readonly property bool animationsEnabled: Plasmoid.configuration.animationsEnabled
    readonly property real animMultiplier: 100 / Math.max(40, Plasmoid.configuration.animationSpeed)
    readonly property string accent: Plasmoid.configuration.accentColor
    readonly property int cornerRadius: Plasmoid.configuration.cornerRadius
    readonly property bool backgroundEnabled: Plasmoid.configuration.backgroundEnabled
    readonly property bool borderEnabled: Plasmoid.configuration.borderEnabled
    readonly property bool followTheme: Plasmoid.configuration.followSystemTheme
    readonly property color panelBackground: !backgroundEnabled ? "transparent"
        : withAlpha(followTheme ? Kirigami.Theme.backgroundColor : Plasmoid.configuration.backgroundColor, Plasmoid.configuration.backgroundOpacity)
    readonly property color borderColor: (borderEnabled && backgroundEnabled)
        ? (followTheme ? withAlpha(Kirigami.Theme.textColor, 16) : Qt.rgba(1, 1, 1, 0.16))
        : Qt.rgba(0, 0, 0, 0)
    // Primary/secondary text colors. On a transparent panel white reads best, but
    // when the user opts into the Plasma theme we follow its text color instead.
    readonly property color textPrimary: followTheme ? Kirigami.Theme.textColor : "white"
    readonly property color textSecondary: followTheme
        ? withAlpha(Kirigami.Theme.textColor, 75)
        : Qt.rgba(1, 1, 1, 0.74)
    readonly property string idleDotColor: Plasmoid.configuration.idleDotColor
    readonly property string sharingDotColor: Plasmoid.configuration.sharingDotColor
    readonly property string timeText: {
        let fmt = Plasmoid.configuration.use24HourClock ? "HH:mm" : "h:mm"
        if (Plasmoid.configuration.showSeconds) {
            fmt += ":ss"
        }
        if (!Plasmoid.configuration.use24HourClock) {
            fmt += " AP"
        }
        let out = Qt.formatTime(currentTime, fmt)
        if (Plasmoid.configuration.showDate) {
            out = Qt.formatDate(currentTime, "ddd d") + "  " + out
        }
        return out
    }
    readonly property bool eventActive: eventTimer.running || notificationPulse.running

    readonly property bool enableMedia: Plasmoid.configuration.enableMedia
    readonly property bool enableNotifications: Plasmoid.configuration.enableNotifications
    readonly property bool enableKeyboard: Plasmoid.configuration.enableKeyboard
    readonly property bool enableDownloads: Plasmoid.configuration.enableDownloads
    readonly property bool enableScreenSharing: Plasmoid.configuration.enableScreenSharing
    readonly property bool enableSysMonitor: Plasmoid.configuration.enableSysMonitor
    readonly property bool showFps: Plasmoid.configuration.showFps
    readonly property string fpsStyle: Plasmoid.configuration.fpsStyle
    readonly property var compactOrderList: {
        const valid = ["content", "time", "fps"]
        const parts = (Plasmoid.configuration.compactOrder || "").split("-")
        let out = []
        for (let i = 0; i < parts.length; i++) {
            if (valid.indexOf(parts[i]) !== -1 && out.indexOf(parts[i]) === -1) {
                out.push(parts[i])
            }
        }
        for (let j = 0; j < valid.length; j++) {
            if (out.indexOf(valid[j]) === -1) {
                out.push(valid[j])
            }
        }
        return out
    }
    readonly property bool moduleSeparators: Plasmoid.configuration.moduleSeparators
    readonly property var compactVisibleList: {
        let out = []
        for (let i = 0; i < compactOrderList.length; i++) {
            const m = compactOrderList[i]
            if (m === "time") {
                if (activeMode !== 2 || unreadCount === 0) {
                    out.push(m)
                }
            } else if (m === "fps") {
                if (showFps) {
                    out.push(m)
                }
            } else {
                out.push(m)
            }
        }
        return out
    }
    readonly property real cpuUsage: sysLoader.item ? sysLoader.item.cpuUsage : 0
    readonly property real ramUsage: sysLoader.item ? sysLoader.item.ramUsage : 0
    readonly property real cpuTemp: sysLoader.item ? sysLoader.item.cpuTemp : 0
    readonly property bool showCpuStat: Plasmoid.configuration.showCpuStat
    readonly property bool showRamStat: Plasmoid.configuration.showRamStat
    readonly property bool showTempStat: Plasmoid.configuration.showTempStat
    readonly property string statsText: {
        let parts = []
        if (showCpuStat) parts.push("CPU " + Math.round(cpuUsage) + "%")
        if (showRamStat) parts.push("RAM " + Math.round(ramUsage) + "%")
        if (showTempStat && cpuTemp > 0) parts.push(Math.round(cpuTemp) + "°C")
        return parts.join("  ")
    }
    readonly property bool sysReady: statsText.length > 0 && (cpuUsage > 0 || ramUsage > 0 || cpuTemp > 0)
    property bool sysPhase: false
    readonly property bool showSysStats: enableSysMonitor && idleMode && sysPhase && sysReady
    readonly property string clockDisplay: showSysStats ? statsText : timeText
    readonly property int fps: fpsMeter.smoothFrameTime > 0 ? Math.round(1 / fpsMeter.smoothFrameTime) : 0

    readonly property int mediaCount: mediaRepeater.count
    readonly property bool hasMedia: mediaCount > 0
    readonly property bool mediaPlaying: mediaStatus === Mpris.PlaybackStatus.Playing
    readonly property bool showMedia: enableMedia && hasMedia && (mediaPlaying || modeIndex === 0)
    readonly property bool sharingScreen: enableScreenSharing && notificationSettings.notificationsInhibitedByApplication
    readonly property bool hasNotification: enableNotifications && (notificationPulse.running || unreadCount > 0)
    readonly property bool hasJobs: enableDownloads && jobsCount > 0
    readonly property bool sharingWithMedia: sharingScreen && showMedia
    readonly property bool idleMode: !sharingScreen && !eventTimer.running && !hasNotification && !buildTimer.running && !hasJobs && !showMedia
    readonly property bool showGreenDot: idleMode
    readonly property int activeMode: {
        if (buildTimer.running) {
            return 8
        }
        if (sharingWithMedia) {
            return 0
        }
        if (hasNotification) {
            return 2
        }
        if (eventTimer.running && modeIndex !== 0) {
            return modeIndex
        }
        if (hasJobs) {
            return 5
        }
        if (showMedia) {
            return 0
        }
        if (sharingScreen) {
            return 7
        }
        return 3
    }
    readonly property string compactTitle: {
        if (showGreenDot) {
            return ""
        }
        if (activeMode === 0) {
            return mediaTitle || Tr.t("Music")
        }
        if (activeMode === 2) {
            return notificationTitle || Tr.t("Notification")
        }
        if (activeMode === 3) {
            return eventTimer.running ? (keyboardLongName || keyboardShortName || Tr.t("Keyboard layout")) : ""
        }
        if (activeMode === 5) {
            return jobsCount > 0 ? Tr.t("Download active") : Tr.t("Downloads")
        }
        if (activeMode === 7) {
            return Tr.t("Sharing screen")
        }
        if (activeMode === 8) {
            return buildLabel || (buildSuccess ? Tr.t("Build succeeded") : Tr.t("Build failed"))
        }
        return ""
    }

    property int modeIndex: 0
    property bool popupOpen: false
    property int mediaStatus: Mpris.PlaybackStatus.Stopped
    property int unreadCount: 0
    property int jobsCount: 0
    property int jobsPercent: 0
    property real mediaPosition: 0
    property real mediaLength: 0
    readonly property real mediaProgress: mediaLength > 0 ? Math.max(0, Math.min(1, mediaPosition / mediaLength)) : 0
    property date currentTime: new Date()
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaArtUrl: ""
    property string mediaIdentity: ""
    property string notificationTitle: ""
    property string notificationBody: ""
    property string notificationIcon: "notifications"
    property string notificationApp: ""
    property var notificationActionNames: []
    property var notificationActionLabels: []
    property bool notificationHasDefaultAction: false
    property string keyboardShortName: ""
    property string keyboardLongName: ""
    property bool keyboardReady: false
    property var mediaContainer: null
    property bool buildSuccess: true
    property string buildLabel: ""
    property string buildApp: ""

    Layout.minimumWidth: compactWidth
    Layout.minimumHeight: compactHeight
    Layout.preferredWidth: compactWidth
    Layout.preferredHeight: compactHeight
    Layout.maximumWidth: compactWidth
    Layout.maximumHeight: compactHeight

    implicitWidth: Layout.preferredWidth
    implicitHeight: Layout.preferredHeight

    TextMetrics {
        id: compactTitleMetrics
        text: root.compactTitle
        font.pointSize: 12
        font.weight: Font.Medium
    }

    TextMetrics {
        id: compactTimeMetrics
        text: root.clockDisplay
        font.pointSize: root.showSysStats ? 12 : 16
        font.weight: Font.Medium
    }

    // Isolated in its own file so an unavailable sensors module can never break
    // the whole widget — the Loader just fails and stats fall back to the clock.
    Loader {
        id: sysLoader
        active: root.enableSysMonitor
        source: "SystemMonitor.qml"
    }

    FrameAnimation {
        id: fpsMeter
        running: root.showFps
    }

    Timer {
        id: sysRotateTimer
        interval: Math.max(3, Plasmoid.configuration.sysMonitorInterval) * 1000
        running: root.enableSysMonitor && root.idleMode
        repeat: true
        onTriggered: root.sysPhase = !root.sysPhase
        onRunningChanged: if (!running) root.sysPhase = false
    }

    function dur(ms) {
        return animationsEnabled ? Math.round(ms * animMultiplier) : 0
    }

    function withAlpha(hex, percent) {
        const c = Qt.lighter(hex, 1.0)
        return Qt.rgba(c.r, c.g, c.b, Math.max(0, Math.min(100, percent)) / 100)
    }

    function setMedia(roleModel) {
        mediaTitle = roleModel.track || ""
        mediaArtist = roleModel.artist || roleModel.identity || ""
        mediaArtUrl = roleModel.artUrl || ""
        mediaIdentity = roleModel.identity || ""
        mediaStatus = roleModel.playbackStatus
        mediaPosition = roleModel.position || 0
        mediaLength = roleModel.length || 0
        mediaContainer = roleModel.container
    }

    function setNotification(roleModel) {
        notificationTitle = roleModel.summary || roleModel.applicationName || Tr.t("Notification")
        notificationBody = roleModel.body || roleModel.text || ""
        notificationApp = roleModel.applicationName || ""
        notificationIcon = roleModel.applicationIconName || roleModel.iconName || "notifications"
        if (notificationIcon.length === 0) {
            notificationIcon = "notifications"
        }
        notificationActionNames = roleModel.actionNames || []
        notificationActionLabels = roleModel.actionLabels || []
        notificationHasDefaultAction = roleModel.hasDefaultAction || false
    }

    function dismissNotification() {
        if (unreadCount > 0) {
            notificationsModel.close(notificationsModel.index(0, 0))
        }
        notificationPulse.stop()
    }

    // Activates the notification's default action — usually raising or opening the
    // source application. No-op when the notification doesn't declare one.
    function activateNotification() {
        if (notificationHasDefaultAction) {
            notificationsModel.invokeDefaultAction(notificationsModel.index(0, 0))
        }
        closePopup()
    }

    function invokeNotificationAction(i) {
        const names = notificationActionNames
        if (i < 0 || i >= names.length) {
            return
        }
        notificationsModel.invokeAction(notificationsModel.index(0, 0), names[i])
        closePopup()
    }

    // Scroll over the capsule controls the active media player: volume when the
    // player exposes it, otherwise skip to the next/previous track.
    function handleWheel(deltaY) {
        if (!showMedia || !mediaContainer || deltaY === 0) {
            return
        }
        const up = deltaY > 0
        if (typeof mediaContainer.volume === "number") {
            const step = 0.05
            mediaContainer.volume = Math.max(0, Math.min(1, mediaContainer.volume + (up ? step : -step)))
        } else if (up) {
            mediaContainer.Next()
        } else {
            mediaContainer.Previous()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date()
            if (root.mediaContainer && root.mediaPlaying) {
                root.mediaContainer.updatePosition()
            }
        }
    }

    Timer {
        id: eventTimer
        interval: 3000
    }

    Timer {
        id: notificationPulse
        interval: 15000
    }

    Timer {
        id: buildTimer
        interval: 6000
    }

    function handleBuildNotification(app, summary, body) {
        if (!Plasmoid.configuration.ideBuildEnabled) {
            return false
        }
        const hay = (app + " " + summary + " " + body).toLowerCase()
        const fromIde = hay.indexOf("intellij") !== -1 || hay.indexOf("idea") !== -1
            || hay.indexOf("jetbrains") !== -1 || hay.indexOf("android studio") !== -1
            || hay.indexOf("gradle") !== -1 || hay.indexOf("maven") !== -1
        const aboutBuild = hay.indexOf("build") !== -1 || hay.indexOf("jar") !== -1
            || hay.indexOf("compil") !== -1 || hay.indexOf("artifact") !== -1
            || hay.indexOf("сборк") !== -1
        if (!fromIde || !aboutBuild) {
            return false
        }
        const failed = hay.indexOf("fail") !== -1 || hay.indexOf("error") !== -1
            || hay.indexOf("ошибк") !== -1 || hay.indexOf("unsuccessful") !== -1
            || hay.indexOf("не удал") !== -1
        buildSuccess = !failed
        buildApp = app || "IntelliJ IDEA"
        buildLabel = summary || (failed ? Tr.t("Build failed") : Tr.t("Build succeeded"))
        buildTimer.restart()
        return true
    }

    Timer {
        id: popupCloseTimer
        interval: 130
        onTriggered: popup.visible = false
    }

    function openPopup() {
        popupCloseTimer.stop()
        popup.visible = true
        popupOpen = true
    }

    function closePopup() {
        popupOpen = false
        popupCloseTimer.restart()
    }

    function togglePopup() {
        if (popupOpen) {
            closePopup()
        } else {
            openPopup()
        }
    }

    WorkspaceComponents.KeyboardLayoutSwitcher {
        id: keyboardLayoutSwitcher

        width: 1
        height: 1
        visible: false
        acceptedButtons: Qt.NoButton

        readonly property string currentShortName: layoutNames.shortName || layoutNames.displayName || ""
        readonly property string currentLongName: layoutNames.longName || layoutNames.displayName || currentShortName

        Component.onCompleted: root.updateKeyboardLayout(false)
        onCurrentShortNameChanged: root.updateKeyboardLayout(root.keyboardReady)
    }

    function updateKeyboardLayout(announce) {
        keyboardShortName = normalizeLayoutName(keyboardLayoutSwitcher.currentShortName)
        keyboardLongName = keyboardLayoutSwitcher.currentLongName
        if (announce && enableKeyboard && keyboardShortName.length > 0) {
            modeIndex = 3
            eventTimer.restart()
        }
        keyboardReady = true
    }

    function normalizeLayoutName(name) {
        const lower = (name || "").toLowerCase()
        if (lower === "us" || lower === "en" || lower.indexOf("english") !== -1) {
            return "Eng"
        }
        if (lower === "ru" || lower.indexOf("russian") !== -1 || lower.indexOf("рус") !== -1) {
            return "Ru"
        }
        return name || ""
    }

    NotificationManager.Settings {
        id: notificationSettings
    }

    NotificationManager.Notifications {
        id: notificationsModel
        limit: 1
        showExpired: false
        showDismissed: false
        showNotifications: true
        showJobs: true
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.DescendingOrder
        groupMode: NotificationManager.Notifications.GroupDisabled

        onUnreadNotificationsCountChanged: {
            root.unreadCount = unreadNotificationsCount
            if (unreadNotificationsCount > 0 && root.enableNotifications) {
                notificationPulse.restart()
            }
        }

        onActiveJobsCountChanged: {
            root.jobsCount = activeJobsCount
            if (activeJobsCount > 0 && root.enableDownloads) {
                root.modeIndex = 5
                eventTimer.restart()
            }
        }

        onJobsPercentageChanged: root.jobsPercent = jobsPercentage

        Component.onCompleted: {
            root.unreadCount = unreadNotificationsCount
            root.jobsCount = activeJobsCount
            root.jobsPercent = jobsPercentage
        }
    }

    Connections {
        target: NotificationManager.Server

        function onNotificationAdded(notification) {
            const app = notification.applicationName || ""
            const summary = notification.summary || ""
            const body = notification.body || notification.text || ""
            if (root.handleBuildNotification(app, summary, body)) {
                return
            }
            if (!root.enableNotifications) {
                return
            }
            root.notificationTitle = summary || app || Tr.t("Notification")
            root.notificationBody = body
            root.notificationApp = app
            root.notificationIcon = notification.applicationIconName || notification.iconName || "notifications"
            if (root.notificationIcon.length === 0) {
                root.notificationIcon = "notifications"
            }
            root.notificationActionNames = notification.actionNames || []
            root.notificationActionLabels = notification.actionLabels || []
            root.notificationHasDefaultAction = notification.hasDefaultAction || false
            notificationPulse.restart()
        }
    }

    Repeater {
        model: notificationsModel

        Item {
            readonly property string summaryValue: model.summary || ""
            readonly property string bodyValue: model.body || ""
            readonly property string appValue: model.applicationName || ""
            readonly property string appIconValue: model.applicationIconName || ""
            readonly property string iconValue: model.iconName || ""
            readonly property var actionsValue: model.actionNames || []

            visible: false
            Component.onCompleted: root.setNotification(model)
            onSummaryValueChanged: root.setNotification(model)
            onBodyValueChanged: root.setNotification(model)
            onActionsValueChanged: root.setNotification(model)
        }
    }

    Repeater {
        id: mediaRepeater

        model: Mpris.MultiplexerModel {
        }

        Item {
            readonly property string trackValue: model.track || ""
            readonly property string artistValue: model.artist || ""
            readonly property string artValue: model.artUrl || ""
            readonly property int statusValue: model.playbackStatus
            readonly property real positionValue: model.position || 0
            readonly property real lengthValue: model.length || 0

            visible: false
            Component.onCompleted: {
                if (index === 0) {
                    root.setMedia(model)
                }
            }
            onTrackValueChanged: if (index === 0) root.setMedia(model)
            onArtistValueChanged: if (index === 0) root.setMedia(model)
            onArtValueChanged: if (index === 0) root.setMedia(model)
            onPositionValueChanged: if (index === 0) root.setMedia(model)
            onLengthValueChanged: if (index === 0) root.setMedia(model)
            onStatusValueChanged: {
                if (index === 0) {
                    root.setMedia(model)
                    if (model.playbackStatus === Mpris.PlaybackStatus.Playing && root.enableMedia) {
                        root.modeIndex = 0
                        eventTimer.restart()
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                if (root.activeMode === 2 && root.unreadCount > 0) {
                    root.dismissNotification()
                }
                return
            }
            root.togglePopup()
        }
        onWheel: (wheel) => root.handleWheel(wheel.angleDelta.y)
    }

    onActiveModeChanged: if (animationsEnabled) islandPop.restart()

    Rectangle {
        id: island

        anchors.centerIn: parent
        width: root.compactWidth
        height: root.compactHeight
        radius: height / 2
        color: "transparent"
        border.width: 0
        transformOrigin: Item.Center

        Behavior on color { ColorAnimation { duration: root.animationsEnabled ? Math.round(160 * root.animMultiplier) : 0 } }
        Behavior on opacity { NumberAnimation { duration: root.animationsEnabled ? Math.round(140 * root.animMultiplier) : 0; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: root.animationsEnabled ? Math.round(220 * root.animMultiplier) : 0; easing.type: Easing.OutCubic } }

        SequentialAnimation {
            id: islandPop

            NumberAnimation { target: island; property: "scale"; to: 1.06; duration: root.animationsEnabled ? Math.round(110 * root.animMultiplier) : 0; easing.type: Easing.OutCubic }
            NumberAnimation { target: island; property: "scale"; to: 1.0; duration: root.animationsEnabled ? Math.round(170 * root.animMultiplier) : 0; easing.type: Easing.OutBack }
        }

        Loader {
            id: compactLoader

            anchors.fill: parent
            sourceComponent: compactContent

            onLoaded: {
                item.opacity = 0
                item.scale = 0.96
                compactFade.target = item
                compactScale.target = item
                compactFade.restart()
                compactScale.restart()
            }
        }

        NumberAnimation {
            id: compactFade
            property: "opacity"
            to: 1
            duration: root.animationsEnabled ? Math.round(120 * root.animMultiplier) : 0
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: compactScale
            property: "scale"
            to: 1
            duration: root.animationsEnabled ? Math.round(160 * root.animMultiplier) : 0
            easing.type: Easing.OutCubic
        }
    }

    PlasmaCore.Dialog {
        id: popup

        visualParent: root
        location: Plasmoid.location
        visible: false
        x: Math.round((root.compactWidth - root.expandedWidth) / 2)
        y: root.compactHeight + Plasmoid.configuration.popupGap
        hideOnWindowDeactivate: true
        backgroundHints: PlasmaCore.Dialog.NoBackground

        Component.onCompleted: flags = flags | Qt.WindowStaysOnTopHint

        // Visibility is driven imperatively (openPopup/closePopup). If the window
        // manager hides the dialog itself (e.g. losing focus while switching
        // monitors) reset the open state so it cannot linger on another screen.
        onVisibleChanged: {
            if (!visible) {
                popupCloseTimer.stop()
                root.popupOpen = false
            }
        }

        mainItem: Item {
            width: root.expandedWidth
            height: root.expandedHeight
            opacity: root.popupOpen ? 1 : 0
            scale: root.popupOpen ? 1 : 0.92

            Behavior on opacity { NumberAnimation { duration: root.animationsEnabled ? Math.round(130 * root.animMultiplier) : 0; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: root.animationsEnabled ? Math.round(170 * root.animMultiplier) : 0; easing.type: Easing.OutBack } }

            MouseArea {
                id: popupMouseArea

                anchors.fill: parent
                hoverEnabled: true
                onExited: root.closePopup()
            }

            Rectangle {
                anchors.fill: parent
                radius: root.cornerRadius
                color: root.panelBackground
                border.width: root.borderEnabled && root.backgroundEnabled ? 1 : 0
                border.color: root.borderColor

                Loader {
                    id: expandedLoader

                    anchors.fill: parent
                    sourceComponent: expandedContent

                    onLoaded: {
                        item.opacity = 0
                        item.scale = 0.97
                        expandedFade.target = item
                        expandedScale.target = item
                        expandedFade.restart()
                        expandedScale.restart()
                    }
                }
            }
        }
    }

    NumberAnimation {
        id: expandedFade
        property: "opacity"
        to: 1
        duration: 120
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: expandedScale
        property: "scale"
        to: 1
        duration: 160
        easing.type: Easing.OutCubic
    }

    Component {
        id: compactContent

        RowLayout {
            id: compactLayout

            anchors.fill: parent
            anchors.leftMargin: root.compactSidePadding
            anchors.rightMargin: root.compactSidePadding
            spacing: root.moduleSeparators ? 6 : 8

            Repeater {
                model: root.compactVisibleList

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: modelData === "content"
                    spacing: root.moduleSeparators ? 6 : 8

                    PlasmaComponents.Label {
                        visible: index > 0 && root.moduleSeparators
                        text: "/"
                        color: Qt.rgba(1, 1, 1, 0.4)
                        font.pointSize: 15
                        font.weight: Font.Light
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Loader {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: modelData === "content"
                        sourceComponent: modelData === "time" ? compactTimeBlock
                                       : modelData === "fps" ? compactFpsBlock
                                       : compactContentBlock
                    }
                }
            }
        }
    }

    Component {
        id: compactContentBlock

        RowLayout {
            spacing: 8

            Rectangle {
                id: sharingDot
                visible: root.sharingWithMedia
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                radius: 5
                color: root.sharingDotColor
                transformOrigin: Item.Center

                SequentialAnimation on opacity {
                    running: sharingDot.visible && root.animationsEnabled
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: root.dur(700); easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: root.dur(700); easing.type: Easing.InOutSine }
                }
            }

            SoundBars {
                visible: root.activeMode === 0
                playing: root.mediaPlaying
                Layout.preferredWidth: 30
                Layout.preferredHeight: 26
            }

            Item {
                visible: root.activeMode === 0
                Layout.preferredWidth: 6
                Layout.preferredHeight: 1
            }

            MediaCompactIcon {
                visible: root.activeMode === 0
                artUrl: root.mediaArtUrl
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
            }

            Rectangle {
                id: idleDot
                visible: root.showGreenDot
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                radius: 5
                color: root.idleDotColor
                transformOrigin: Item.Center

                SequentialAnimation on scale {
                    running: root.showGreenDot && root.animationsEnabled
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.35; duration: root.dur(900); easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: root.dur(900); easing.type: Easing.InOutSine }
                }

                SequentialAnimation on opacity {
                    running: root.showGreenDot && root.animationsEnabled
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.55; duration: root.dur(900); easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: root.dur(900); easing.type: Easing.InOutSine }
                }
            }

            StatusIcon {
                visible: root.activeMode !== 0 && !root.showGreenDot
                mode: root.activeMode
                iconName: root.notificationIcon
                unread: root.unreadCount
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            PlasmaComponents.Label {
                text: root.compactTitle
                visible: !root.showGreenDot && text.length > 0
                color: root.textPrimary
                font.pointSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.maximumWidth: root.compactTextMaxWidth
            }

            Rectangle {
                id: unreadBadge
                visible: root.activeMode === 2 && root.unreadCount > 0
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 6
                color: root.accent
                transformOrigin: Item.Center

                SequentialAnimation on scale {
                    running: unreadBadge.visible && notificationPulse.running && root.animationsEnabled
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.18; duration: root.dur(520); easing.type: Easing.OutCubic }
                    NumberAnimation { to: 1.0; duration: root.dur(520); easing.type: Easing.InCubic }
                }

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: root.unreadCount
                    color: "white"
                    font.bold: true
                }
            }
        }
    }

    Component {
        id: compactTimeBlock

        PlasmaComponents.Label {
            text: root.clockDisplay
            color: root.textPrimary
            font.pointSize: root.showSysStats ? 12 : 16
            font.weight: Font.Medium
        }
    }

    Component {
        id: compactFpsBlock

        PlasmaComponents.Label {
            text: root.fps + " fps"
            color: root.fpsStyle === "plain" ? root.textPrimary : root.accent
            font.pointSize: root.fpsStyle === "plain" ? 14 : 9
            font.weight: root.fpsStyle === "plain" ? Font.Medium : Font.Bold
        }
    }

    Component {
        id: expandedContent

        Item {
            anchors.fill: parent

            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (root.activeMode === 0) return musicExpanded
                    if (root.activeMode === 2) return notificationExpanded
                    return statusExpanded
                }
            }
        }
    }

    Component {
        id: musicExpanded

        Item {
            anchors.fill: parent

            Image {
                id: musicArt
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 52
                height: 52
                visible: source !== ""
                source: root.mediaArtUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                layer.enabled: true
            }

            Rectangle {
                anchors.fill: musicArt
                visible: root.mediaArtUrl === ""
                radius: 8
                color: Qt.rgba(0.92, 0.94, 0.96, 0.28)

                Kirigami.Icon {
                    anchors.centerIn: parent
                    source: "audio-x-generic"
                    width: 30
                    height: 30
                }
            }

            SoundBars {
                id: musicBars
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 16
                width: 38
                height: 28
                playing: root.mediaPlaying
            }

            Row {
                id: musicControls
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                spacing: 14

                Kirigami.Icon {
                    source: "media-skip-backward"
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root.mediaContainer ? 1 : 0.35

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.mediaContainer) root.mediaContainer.Previous()
                    }
                }

                Kirigami.Icon {
                    source: root.mediaPlaying ? "media-playback-pause" : "media-playback-start"
                    width: 26
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root.mediaContainer ? 1 : 0.35

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.mediaContainer) root.mediaContainer.PlayPause()
                    }
                }

                Kirigami.Icon {
                    source: "media-skip-forward"
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root.mediaContainer ? 1 : 0.35

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.mediaContainer) root.mediaContainer.Next()
                    }
                }
            }

            PlasmaComponents.Label {
                id: musicTitle
                anchors.left: musicArt.right
                anchors.leftMargin: 14
                anchors.right: musicBars.left
                anchors.rightMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 16
                text: root.mediaTitle || Tr.t("No title")
                color: root.textPrimary
                font.pointSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                anchors.left: musicArt.right
                anchors.leftMargin: 14
                anchors.right: musicBars.left
                anchors.rightMargin: 14
                anchors.top: musicTitle.bottom
                anchors.topMargin: 2
                text: root.mediaArtist || root.mediaIdentity || Tr.t("Media player")
                color: root.textSecondary
                font.pointSize: 10
                elide: Text.ElideRight
            }

            Rectangle {
                anchors.left: musicArt.right
                anchors.leftMargin: 14
                anchors.right: musicControls.left
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22
                height: 5
                radius: 3
                color: Qt.rgba(1, 1, 1, 0.22)

                Rectangle {
                    width: parent.width * root.mediaProgress
                    height: parent.height
                    radius: parent.radius
                    color: root.accent

                    Behavior on width { NumberAnimation { duration: root.dur(220); easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    Component {
        id: notificationExpanded

        Item {
            id: notifRoot
            anchors.fill: parent

            readonly property bool hasActions: root.notificationActionLabels.length > 0

            StatusIcon {
                id: notifIcon
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 44
                mode: 2
                iconName: root.notificationIcon
                unread: root.unreadCount
            }

            SoundBars {
                id: notifBars
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 14
                width: 32
                height: 24
                playing: notificationPulse.running
            }

            Column {
                anchors.left: notifIcon.right
                anchors.leftMargin: 14
                anchors.right: notifBars.left
                anchors.rightMargin: 14
                anchors.top: parent.top
                anchors.topMargin: notifRoot.hasActions ? 12 : 0
                anchors.verticalCenter: notifRoot.hasActions ? undefined : parent.verticalCenter
                spacing: 3

                PlasmaComponents.Label {
                    width: parent.width
                    text: root.notificationTitle || Tr.t("Notification")
                    color: root.textPrimary
                    font.pointSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    width: parent.width
                    text: root.notificationBody || root.notificationApp || (root.unreadCount > 0 ? Tr.tr("%1 unread", root.unreadCount) : Tr.t("New notification"))
                    color: root.textSecondary
                    font.pointSize: 10
                    wrapMode: Text.WordWrap
                    maximumLineCount: notifRoot.hasActions ? 1 : Plasmoid.configuration.notificationBodyLines
                    elide: Text.ElideRight
                }
            }

            // Click the icon/text region to trigger the default action (open the app).
            MouseArea {
                anchors.left: parent.left
                anchors.right: notifBars.left
                anchors.top: parent.top
                anchors.bottom: notifRoot.hasActions ? notifActions.top : parent.bottom
                enabled: root.notificationHasDefaultAction
                onClicked: root.activateNotification()
            }

            Row {
                id: notifActions
                visible: notifRoot.hasActions
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                spacing: 8

                Repeater {
                    model: Math.min(2, root.notificationActionLabels.length)

                    ActionPill {
                        label: root.notificationActionLabels[index] || ""
                        onTriggered: root.invokeNotificationAction(index)
                    }
                }
            }
        }
    }

    Component {
        id: statusExpanded

        Item {
            id: statusRoot
            anchors.fill: parent

            readonly property bool hasProgress: root.activeMode === 5 || root.activeMode === 8

            StatusIcon {
                id: statusIcon
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 44
                mode: root.activeMode
                iconName: root.notificationIcon
                unread: root.unreadCount
            }

            Column {
                anchors.left: statusIcon.right
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                PlasmaComponents.Label {
                    width: parent.width
                    text: root.activeMode === 3 ? (root.keyboardLongName || root.keyboardShortName || Tr.t("Keyboard layout")) : root.compactTitle
                    color: root.textPrimary
                    font.pointSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    width: parent.width
                    text: root.activeMode === 1 ? Tr.t("Volume") :
                          root.activeMode === 3 ? Tr.t("Keyboard layout") :
                          root.activeMode === 4 ? Tr.t("Pomodoro session in progress") :
                          root.activeMode === 5 ? (root.jobsCount > 0 ? Tr.tr("%1% complete", root.jobsPercent) : Tr.t("No active downloads")) :
                          root.activeMode === 6 ? Tr.t("Connected") :
                          root.activeMode === 7 ? Tr.t("Active capture or presentation mode") :
                          root.activeMode === 8 ? (root.buildApp + (root.buildSuccess ? " · " + Tr.t("success") : " · " + Tr.t("failed"))) : Tr.t("Status")
                    color: root.textSecondary
                    font.pointSize: 10
                    elide: Text.ElideRight
                }

                Rectangle {
                    visible: statusRoot.hasProgress
                    width: parent.width
                    height: 5
                    radius: 3
                    color: Qt.rgba(1, 1, 1, 0.18)

                    Rectangle {
                        width: parent.width * (root.activeMode === 8 ? (root.buildSuccess ? 1 : 0.4) :
                                               root.jobsPercent > 0 ? root.jobsPercent / 100 : 0.05)
                        height: parent.height
                        radius: parent.radius
                        color: root.activeMode === 8 ? (root.buildSuccess ? "#55e36a" : "#ff4f6f") : root.accent

                        Behavior on width { NumberAnimation { duration: root.dur(260); easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }

    component StatusIcon: Item {
        property int mode: 0
        property int unread: 0
        property string iconName: "notifications"

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: mode === 1 ? Qt.rgba(0.35, 0.42, 0.52, 0.35) :
                   mode === 2 ? "#2da6e8" :
                   mode === 3 ? Qt.rgba(0.5, 0.56, 0.68, 0.38) :
                   mode === 4 ? "#e84855" :
                   mode === 5 ? Qt.rgba(0.12, 0.6, 0.95, 0.34) :
                   mode === 6 ? Qt.rgba(0.2, 0.9, 0.35, 0.24) :
                   mode === 7 ? Qt.rgba(0.25, 1, 0.15, 0.28) :
                   mode === 8 ? (root.buildSuccess ? Qt.rgba(0.33, 0.89, 0.41, 0.30) : Qt.rgba(0.92, 0.30, 0.36, 0.32)) :
                   Qt.rgba(0.55, 0.4, 1, 0.3)

            Behavior on color { ColorAnimation { duration: root.dur(160) } }
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            width: parent.width * 0.62
            height: width
            source: mode === 1 ? "audio-volume-high" :
                    mode === 2 ? iconName :
                    mode === 3 ? "input-keyboard" :
                    mode === 4 ? "chronometer" :
                    mode === 5 ? "download" :
                    mode === 6 ? "security-high" :
                    mode === 7 ? "krfb" :
                    mode === 8 ? (root.buildSuccess ? "emblem-success" : "emblem-error") :
                    "utilities-terminal"
        }
    }

    component ActionPill: Rectangle {
        property string label: ""
        signal triggered()

        height: 26
        width: pillLabel.implicitWidth + 24
        radius: height / 2
        color: pillMouse.pressed ? Qt.lighter(root.accent, 1.15) : root.accent

        Behavior on color { ColorAnimation { duration: root.dur(120) } }

        PlasmaComponents.Label {
            id: pillLabel
            anchors.centerIn: parent
            text: parent.label
            color: "white"
            font.pointSize: 10
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            onClicked: parent.triggered()
        }
    }

    component MediaCompactIcon: Item {
        property string artUrl: ""

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Qt.rgba(1, 1, 1, 0.12)
            visible: artUrl.length === 0

            Kirigami.Icon {
                anchors.centerIn: parent
                width: parent.width * 0.7
                height: width
                source: "audio-x-generic"
            }
        }

        Image {
            anchors.fill: parent
            visible: artUrl.length > 0
            source: artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    component SoundBars: Row {
        property bool playing: false

        spacing: 5
        width: 44
        height: 34

        Repeater {
            model: [18, 27, 14, 24, 20]

            Rectangle {
                id: bar

                width: 4
                height: modelData
                y: (parent.height - height) / 2
                radius: 2
                color: root.textPrimary
                opacity: playing ? 0.9 : 0.55
                transformOrigin: Item.Center
                transform: Scale {
                    id: barScale
                    origin.x: bar.width / 2
                    origin.y: bar.height / 2
                    xScale: 1
                    yScale: playing ? 1 : 0.45

                    SequentialAnimation on yScale {
                        running: playing
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 0.35 + ((index * 17) % 45) / 100
                            duration: 260 + index * 45
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 1
                            duration: 260 + index * 45
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }
    }
}
