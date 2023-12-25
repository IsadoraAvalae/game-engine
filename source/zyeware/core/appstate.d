// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright 2021 ZyeByte
module zyeware.core.appstate;

public import zyeware.core.application : StateApplication;

import zyeware;

/// A game state is used in conjunction with a `StateApplication` instance
/// to make managing an application with different states easier.
abstract class AppState
{
private:
    StateApplication mApplication;

package(zyeware.core):
    bool mWasAlreadyAttached;

protected:
    this(StateApplication application) pure nothrow
        in (application, "Parent application cannot be null.")
    {
        mApplication = application;
    }

public:
    /// Override this function to perform logic every frame.
    ///
    /// Params:
    ///     frameTime = The time between this frame and the last.
    abstract void tick();

    /// Override this function to perform rendering.
    abstract void draw();
    
    /// Called when this game state gets attached to a `StateApplication`.
    ///
    /// Params:
    ///     firstTime = Whether it gets attached the first time or not.
    void onAttach(bool firstTime) {}

    /// Called when this game state gets detached from a `StateApplication`.
    void onDetach() {}

    /// The application this game state is registered to.
    inout(StateApplication) application() pure inout nothrow
    {
        return mApplication;
    }

    /// Whether this game state was already attached once or not.
    bool wasAlreadyAttached() pure const nothrow
    {
        return mWasAlreadyAttached;
    }
}