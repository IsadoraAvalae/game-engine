module zyeware.core.math.matrix;

import inmath.math;
import inmath.linalg;
public import inmath.linalg : quat, mat2, mat3, mat4;

import zyeware;

/// Convert a 2D position from world to local space.
/// 
/// Params:
/// 	worldPoint = The 2D position in world space.
/// 
/// Returns: The position in local space.
vec2 inverseTransformPoint(in mat4 transform, in vec2 worldPoint) pure nothrow
{
    return (transform.inverse * vec4(worldPoint, 0, 1)).xy;
}

/// Convert a 2D position from local to world space.
/// 
/// Params:
/// 	localPoint = The 2D position in local space.
/// 
/// Returns: The position in world space.
vec2 transformPoint(in mat4 transform, in vec2 localPoint) pure nothrow
{
    return (transform * vec4(localPoint, 0, 1)).xy;
}

/// Convert a 3D position from world to local space.
/// 
/// Params:
/// 	worldPoint = The 3D position in world space.
/// 
/// Returns: The position in local space.
vec3 inverseTransformPoint(in mat4 transform, in vec3 worldPoint) pure nothrow
{
    return (transform.inverse * vec4(worldPoint, 1)).xyz;
}

/// Convert a 3D position from local to world space.
/// 
/// Params:
/// 	localPoint = The 3D position in local space.
/// 
/// Returns: The position in world space.
vec3 transformPoint(in mat4 transform, in vec3 localPoint) pure nothrow
{
    return (transform * vec4(localPoint, 1)).xyz;
}