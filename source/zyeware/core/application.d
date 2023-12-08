// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright 2021 ZyeByte
module zyeware.core.application;

import core.memory : GC;
import std.algorithm : min;
import std.typecons : Nullable;

public import zyeware.core.appstate;
import zyeware;
import zyeware.utils.collection;


/// Represents an application that can be run by ZyeWare.
/// To write a ZyeWare app, you must inherit from this class and return an
/// instance of it with the `getProjectProperties` function.
///
/// Examples:
/// --------------------
/// class MyApplication : Application
/// {
///     ...    
/// }
///
/// extern(C) ProjectProperties getProjectProperties();
/// {
///     ProjectProperties props;
///     props.application = new MyApplication();
///     return props;
/// }
/// --------------------
abstract class Application
{
public:
    /// Override this method for application initialization.
    abstract void initialize();

    /// Override this method to perform logic on every frame.
    abstract void tick();

    /// Override this method to perform rendering.
    abstract void draw();

    /// Destroys the application.
    void cleanup() {}
    
    /// Handles the specified event in whatever manners seem appropriate.
    ///
    /// Params:
    ///     ev = The event to handle.
    void receive(in Event ev)
        in (ev, "Received event cannot be null.")
    {
        if (cast(QuitEvent) ev)
            ZyeWare.quit();
    }
}

/// A ZyeWare application that takes care of the game state logic.
/// Game states can be set, pushed and popped.
class StateApplication : Application
{
private:
    enum deferWarning = "Changing game state during event emission can cause instability. Use a deferred call instead.";

protected:
    GrowableStack!AppState mStateStack;

public:
    override void receive(in Event ev)
        in (ev, "Received event cannot be null.")
    {
        super.receive(ev);

        if (hasState)
            currentState.receive(ev);
    }

    override void tick()
    {
        if (hasState)
            currentState.tick();
    }

    override void draw()
    {
        if (hasState)
            currentState.draw();
    }

    /// Change the current state to the given one.
    /// This method should not be called during event emission. Use a deferred call
    /// for this purpose.
    ///
    /// Params:
    ///     state = The game state to switch to.
    /// See_Also: ZyeWare.callDeferred
    void changeState(AppState state)
        in (state, "Game state cannot be null.")
    {
        debug if (ZyeWare.isEmittingEvent)
            Logger.core.log(LogLevel.warning, deferWarning);

        if (hasState)
            mStateStack.pop().onDetach();
        
        mStateStack.push(state);
        state.onAttach(!state.mWasAlreadyAttached);
        state.mWasAlreadyAttached = true;
        ZyeWare.collect();
    }

    /// Pushes the given state onto the stack, and switches to it.
    /// This method should not be called during event emission. Use a deferred call
    /// for this purpose.
    ///
    /// Params:
    ///     state = The state to push and switch to.
    /// See_Also: ZyeWare.callDeferred
    void pushState(AppState state)
        in (state, "Game state cannot be null.")
    {
        debug if (ZyeWare.isEmittingEvent)
            Logger.core.log(LogLevel.warning, deferWarning);

        if (hasState)
            currentState.onDetach();
        
        mStateStack.push(state);
        state.onAttach(!state.mWasAlreadyAttached);
        state.mWasAlreadyAttached = true;
        ZyeWare.collect();
    }

    /// Pops the current state from the stack, restoring the previous state.
    /// This method should not be called during event emission. Use a deferred call
    /// for this purpose.
    /// See_Also: ZyeWare.callDeferred
    void popState()
    {
        debug if (ZyeWare.isEmittingEvent)
            Logger.core.log(LogLevel.warning, deferWarning);

        if (hasState)
            mStateStack.pop().onDetach();
        
        currentState.onAttach(!currentState.mWasAlreadyAttached);
        currentState.mWasAlreadyAttached = true;
        ZyeWare.collect();
    }

    /// The current game state.
    pragma(inline, true)
    AppState currentState()
    {
        return mStateStack.peek;
    }

    /// If this application currently has a game state loaded.
    pragma(inline, true)
    bool hasState() const nothrow
    {
        return !mStateStack.empty;
    }
}
