// D import file generated from 'source/zyeware/core/introapp.d'
module zyeware.core.introapp;
import zyeware.common;
import zyeware.rendering;
package(zyeware.core) final class IntroApplication : Application
{
	protected
	{
		Texture2D mEngineLogo;
		Application mMainApplication;
		OrthographicCamera mCamera;
		BitmapFont mInternalFont;
		string mVersionString;
		Gradient mBackgroundGradient;
		Interpolator!(float, lerp) mAlphaInterpolator;
		Interpolator!(float, lerp) mScaleInterpolator;
		package(zyeware)
		{
			this(Application mainApplication);
			public
			{
				override void initialize();
				override void cleanup();
				override void receive(in Event ev);
				override void tick(in FrameTime frameTime);
				override void draw(in FrameTime nextFrameTime);
			}
		}
	}
}
