// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright 2021 ZyeByte
module zyeware.core.crash;

import std.string : format;

import zyeware;

/// A `CrashHandler` is responsible for gracefully handling an unhandled `Throwable`.
/// The handler must expect the engine to close immediately after handling.
interface CrashHandler
{
    /// Handles the specified throwable.
    ///
    /// Params:
    ///     t = The throwable to handle.
    void show(Throwable t);
}

/// The default crash handler, used in absence of any other. Only displays the error
/// to the console.
class DefaultCrashHandler : CrashHandler
{
public:
    /// Handles the specified throwable.
    ///
    /// Params:
    ///     t = The throwable to handle.
    void show(Throwable t)
        in (t, "Throwable cannot be null.")
    {
        import std.string : split, startsWith;

        fatal("==================== Unhandled throwable '%s' ====================",
            typeid(t).toString().split(".")[$-1]);
        fatal("Details: %s", t.message);

        foreach (trace; t.info)
            if (!trace.startsWith("??:?"))
                info(trace);
        
        fatal("------------------------------");
        fatal("If you suspect that this is a ZyeWare issue, please leave a bug report over at https://github.com/zyebytevt/zyeware!");
        fatal("=================================================================");
    }
}

/// The default crash handler for Linux operating systems.
version (linux)
class LinuxDefaultCrashHandler : DefaultCrashHandler
{
    import std.process : execute, executeShell;

private:
    enum popupTitle = "Fatal Error";
    enum popupDescription = "Please notify the developer about this issue.\nAdditionally, if this is a bug"
    ~ " in the engine, please leave a bug report over at https://github.com/zyebytevt/zyeware.";
    enum popupMoreDetails = "For more details, please look into the logs.";

protected:
    bool commandExists(string command)
    {
        return executeShell("type " ~ command).status == 0;
    }

    void showKDialog(Throwable t)
    {
        execute([
            "kdialog",
            "--detailederror",
            t.message,
            t.toString(),
            "--title",
            popupTitle,
            "--ok-label",
            "Close ZyeWare"
        ]);
    }

    void showZenity(in Throwable t)
    {
        immutable string message =
            format!"<span size='x-large' weight='bold'>%s</span>\n\n%s\n%s"(t.message, popupDescription, popupMoreDetails);

        auto result = execute([
            "zenity",
            "--error",
            "--text",
            message,
            "--title",
            popupTitle,
            "--width",
            "500",
            "--ok-label",
            "Close ZyeWare"
        ]);
    }

    void showXMessage(in Throwable t)
    {
        immutable string message =
            format!"%s\n\n%s\n%s"(t.message, popupDescription, popupMoreDetails);

        execute([
            "xmessage",
            "-buttons",
            "Close ZyeWare:0",
            "-center",
            message
        ]);
    }

    void showGXMessage(in Throwable t)
    {
        immutable string message =
            format!"%s\n\n%s\n%s"(t.message, popupDescription, popupMoreDetails);

        execute([
            "gxmessage",
            "-ontop",
            "-buttons",
            "Close ZyeWare:0",
            "-title",
            popupTitle,
            "-center",
            message
        ]);
    }

public:
    override void show(Throwable t)
    {
        super.show(t);

        if (commandExists("kdialog"))
            showKDialog(t);
        else if (commandExists("zenity"))
            showZenity(t);
        else if (commandExists("gxmessage"))
            showGXMessage(t);
        else if (commandExists("xmessage"))
            showXMessage(t);
        else
        {
            warning("Could not find appropriate message box application to use.");
            warning("I hope you're looking at the logs!");
        }
    }
}

/// The default crash handler for Windows operating systems.
version (Windows)
class WindowsDefaultCrashHandler : DefaultCrashHandler
{
    import core.sys.windows.windows;
    import std.utf : toUTFz;

protected:
    void showMessageBox(string message, string title)
    {
        MessageBoxW(null, message.toUTFz!(const(wchar)*), title.toUTFz!(const(wchar)*), MB_OK | MB_ICONERROR);
    }

    // TODO: Couldn't get TaskDialog to work as apparently, there is no declaration for it in D.
    // Manually declaring it also didn't work. Whenever someone gets to it, replacing the MessageBox
    // with a TaskDialog would be nice.

public:
    override void show(Throwable t)
    {
        super.show(t);

        enum title = "Can I go home yet?";
        enum message = "As it turns out, the application has crashed. ZyeByte is sorry for the inconvenience, be it as "
        ~ "the game or engine developer alike.\nIf you do suspect it's an issue of the engine though, please leave "
        ~ "a bug report over at https://github.com/zyebytevt/zyeware!\nWith this, I'm sure it can be fixed soon.\n\n"
        ~ "(Restarting often fixes issues, I've been told!)";

        showMessageBox(message ~ "\n\n" ~ t.toString(), title);
    }
}