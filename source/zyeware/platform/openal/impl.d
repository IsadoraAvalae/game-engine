// This file is part of the ZyeWare Game Engine, and subject to the terms
// and conditions defined in the file 'LICENSE.txt', which is part
// of this source code package.
//
// Copyright 2021 ZyeByte
module zyeware.platform.openal.impl;

version (ZWBackendOpenAL):
package(zyeware):

import zyeware.audio;

import zyeware.platform.openal.api;
import zyeware.platform.openal.buffer;
import zyeware.platform.openal.source;

void loadOpenALBackend()
{
    AudioAPI.sInitializeImpl = &apiInitialize;
    AudioAPI.sLoadLibrariesImpl = &apiLoadLibraries;
    AudioAPI.sCleanupImpl = &apiCleanup;

    AudioAPI.sAddBusImpl = &apiAddBus;
    AudioAPI.sGetBusImpl = &apiGetBus;
    AudioAPI.sRemoveBusImpl = &apiRemoveBus;
    AudioAPI.sSetListenerLocationImpl = &apiSetListenerLocation;
    AudioAPI.sGetListenerLocationImpl = &apiGetListenerLocation;

    AudioAPI.sCreateSoundImpl = (encMem, props) => new OALSound(encMem, props);
    AudioAPI.sCreateAudioSourceImpl = (bus) => new OALAudioSource(bus);

    AudioAPI.sLoadSoundImpl = (path) => OALSound.load(path);
}