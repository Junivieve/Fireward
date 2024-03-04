/// @desc Particle Logic.
Hsp = lengthdir_x(Spd,Dir)
Vsp = lengthdir_y(Spd,Dir)

x += Hsp
y += Vsp

if(AnimationEnd() && EndOnAnim) || (Tick >= Life && !EndOnAnim) //
{
	instance_destroy()
	exit;
}

Tick++;