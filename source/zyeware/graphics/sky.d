// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright © 2021-2024 ZyeByte. All rights reserved.
module zyeware.graphics.sky;

import zyeware;

/+

class Skybox : Renderable
{
protected:
    BufferGroup mBufferGroup;
    Material mMaterial;

public:
    this(TextureCubeMap texture, Shader shader = null)
        in (texture)
    {
        if (!shader)
            shader = AssetManager.load!Shader("core:shaders/3d/skybox.shd");

        mMaterial = new Material(shader);
        mMaterial.setTexture(0, texture);

        immutable static vec3[] vertices = [
            vec3(-1, 1, -1),
            vec3(-1, -1, -1),
            vec3(-1, -1, 1),
            vec3(-1, 1, 1),
            vec3(1, 1, -1),
            vec3(1, -1, -1),
            vec3(1, -1, 1),
            vec3(1, 1, 1)
        ];

        immutable static uint[] indices = [
            0, 1, 5, 5, 4, 0,
            2, 1, 0, 0, 3, 2,
            5, 6, 7, 7, 4, 5,
            2, 3, 7, 7, 6, 2,
            0, 4, 7, 7, 3, 0,
            1, 2, 5, 5, 2, 6
        ];

        mBufferGroup = BufferGroup.create();
        mBufferGroup.dataBuffer = DataBuffer.create(vertices, BufferLayout([
            BufferElement("aPosition", BufferElement.Type.vec3)
        ]), No.dynamic);

        mBufferGroup.indexBuffer = IndexBuffer.create(indices, No.dynamic);
    }

    inout(BufferGroup) bufferGroup() inout pure nothrow
    {
        return mBufferGroup;
    }

    inout(Material) material() inout pure nothrow
    {
        return mMaterial;
    }
}+/
