// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright 2021 ZyeByte
module zyeware.rendering.environment;

import zyeware;


struct Environment3D
{
    Mesh3D sky;
    col fogColor = col(0, 0, 0, 0.02);
    col ambientColor = col(0.5, 0.5, 0.5, 1);
}