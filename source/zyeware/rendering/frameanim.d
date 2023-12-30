module zyeware.rendering.frameanim;

import std.datetime : dur, Duration;
import std.conv : to;
import std.exception : enforce;

import zyeware;

@asset(Yes.cache)
class FrameAnimations
{
protected:
    Animation[string] mAnimations;

public:
    struct Frame
    {
        size_t index;
        Duration duration;
    }

    /// Represents a single animation.
    struct Animation
    {
        string name;
        Frame[] frames;
        bool isLooping; /// If the animation should loop after the last frame.
        bool hFlip; /// If the animation is horizontally flipped.
        bool vFlip; /// If the animation is vertically flipped.

        Duration duration() pure const nothrow
        {
            auto totalDuration = Duration.zero;
            foreach (ref frame; frames)
                totalDuration += frame.duration;
            return totalDuration;
        }
    }

    /// Adds an animation.
    ///
    /// Params:
    ///     name = The name of the animation to add.
    ///     animation = The animation to add.
    void addAnimation(string name, Animation animation) pure nothrow
        in (name, "Name cannot be null.")
    {
        mAnimations[name] = animation;
        mAnimations[name].name = name;
    }

    /// Removes an animation.
    ///
    /// Params:
    ///     name = The name of the animation to remove.
    void removeAnimation(string name) pure nothrow
        in (name, "Name cannot be null.")
    {
        mAnimations.remove(name);
    }

    /// Returns the animation with the given name.
    ///
    /// Params:
    ///     name = The name of the animation to return.
    /// Returns: Pointer to the animation if found, `null` otherwise.
    Animation* getAnimation(string name) pure
        in (name, "Name cannot be null.")
    {
        return name in mAnimations;
    }

    static FrameAnimations load(string path)
        in (path, "Path cannot be null")
    {
        auto frameAnims = new FrameAnimations();

        SDLNode* root = loadSdlDocument(path ~ ".props");

        for (size_t i; i < root.children.length; ++i)
        {
            SDLNode* node = &root.children[i];

            Animation animation;

            immutable string animationName = node.name;
            
            animation.isLooping = node.getAttributeValue!bool("loop", false);
            animation.hFlip = node.getAttributeValue!bool("hflip", false);
            animation.vFlip = node.getAttributeValue!bool("vflip", false);

            for (size_t j; j < node.children.length; ++j)
            {
                SDLNode* frameNode = &node.children[j];

                size_t startFrame, endFrame, durationMsecs;

                if (frameNode.name == "frame")
                {
                    startFrame = cast(size_t) frameNode.getValue!int();
                    endFrame = startFrame;
                }
                else if (frameNode.name == "frame-range")
                {
                    startFrame = frameNode.expectAttributeValue!size_t("start");
                    endFrame = frameNode.expectAttributeValue!size_t("end");
                }
                else
                    throw new Exception("Invalid frame node name: " ~ frameNode.name);

                durationMsecs = frameNode.expectAttributeValue!size_t("msecs");

                if (endFrame >= startFrame)
                {
                    for (size_t k = startFrame; k <= endFrame; k++)
                        animation.frames ~= Frame(k, dur!"msecs"(durationMsecs));
                }
                else
                {
                    for (size_t k = startFrame; k >= endFrame; k--)
                        animation.frames ~= Frame(k, dur!"msecs"(durationMsecs));
                }
            }

            frameAnims.addAnimation(animationName, animation);
        }

        return frameAnims;
    }
}

@("Frame animations")
unittest
{
    import unit_threaded.assertions;

    // Create a FrameAnimations
    FrameAnimations frameAnims = new FrameAnimations();

    // Add an animation
    FrameAnimations.Animation animation;
    animation.name = "test";
    animation.frames = [FrameAnimations.Frame(0, dur!"msecs"(100))];
    animation.isLooping = true;
    animation.hFlip = false;
    animation.vFlip = false;
    frameAnims.addAnimation("test", animation);
    frameAnims.mAnimations.length.should == 1;

    // Get the animation
    FrameAnimations.Animation* retrievedAnimation = frameAnims.getAnimation("test");
    retrievedAnimation.should.not == null;
    retrievedAnimation.name.should == "test";
    retrievedAnimation.frames.length.should == 1;
    retrievedAnimation.isLooping.should == true;
    retrievedAnimation.hFlip.should == false;
    retrievedAnimation.vFlip.should == false;

    // Remove the animation
    frameAnims.removeAnimation("test");
    frameAnims.mAnimations.length.should == 0;
}