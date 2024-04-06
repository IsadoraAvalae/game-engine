// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright © 2021-2024 ZyeByte. All rights reserved.
module zyeware.ecs.component.render;

import std.datetime : Duration;
import std.typecons : Tuple;
import std.string : format;
import std.exception : enforce;

import zyeware;
import zyeware.ecs;

/// The `SpriteComponent` gives an entity the ability to represent itself
/// with a `Texture2d` with the given parameters.
///
/// See_Also: Texture2d
@component struct SpriteComponent
{
    vec2 size; /// The size of the sprite.
    vec2 offset; /// The offset of the sprite.
    TextureAtlas atlas; /// The texture atlas used for sprite rendering.
    color modulate = color.white; /// The modulation of this sprite.
    Material material = null; /// The material to use for rendering.
    Flag!"hFlip" hFlip; /// If the sprite is horizontally flipped.
    Flag!"vFlip" vFlip; /// If the sprite is vertically flipped.
}

/// The `SpriteAnimationComponent` causes an entity with a `SpriteComponent` to animate
/// through the specified frames.
///
/// See_Also: SpriteAnimationComponent
@component struct SpriteAnimationComponent
{
private:
    SpriteFrames mSpriteFrames;

    string mCurrentAnimationName;

package(zyeware.ecs):
    Duration mCurrentFrameLength;
    SpriteFrames.Animation* mCurrentAnimation;
    size_t mCurrentFrame;

public:
    bool playing; /// Whether the animation is currently playing or not.

    /// Params:
    ///     spriteFrames = The `SpriteFrames` instance to use for animations.
    ///     startAnimation = On which animation to start on.
    ///     autostart = Whether to start playing the animation upon creation or not.
    this(SpriteFrames spriteFrames, string startAnimation, Flag!"autostart" autostart) pure
    in (spriteFrames, "Sprite frames cannot be null.")
    in (startAnimation, "Starting animation cannot be null.")
    {
        mSpriteFrames = spriteFrames;
        this.animation = startAnimation;
        this.playing = autostart;
    }

    /// The name of the currently playing animation.
    string animation() pure nothrow
    {
        return mCurrentAnimationName;
    }

    /// ditto
    void animation(string value) pure
    in (value, "Animation name cannot be null.")
    {
        mCurrentAnimation = mSpriteFrames.getAnimation(value);
        enforce!RenderException(mCurrentAnimation,
            format!"No animation named '%s' was found."(value));

        mCurrentAnimationName = value;
        mCurrentFrame = mCurrentAnimation.startFrame;
        mCurrentFrameLength = mCurrentAnimation.frameInterval;
    }
}

/// The `LightComponent` gives an entity the ability to emit light.
@component struct LightComponent
{
    color modulate; /// The modulate of the light.
    vec3 attenuation; /// The attenuation used.
}
