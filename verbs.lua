std.room.scene = function()
	local title = iface:title(std.titleof(pl:where()))
	local status = std.call(pl:where(), "status")
	if status then
		title = title .. ' ' .. mp.fmt("(" .. status .. ")")
	end
	return title
end

game.before_Default = function(s, ev, w, wh)
	if wh and (ev == 'Cut' or ev == 'Dig' or ev == 'Fill' or ev == 'Burn') then
		if mp:runmethods('before', 'MakeUse', wh, w) then
			return
		end
	end
	return false;
end;
game.after_Default = function(s, ev, w, wh)
	if wh and (ev == 'Cut' or ev == 'Dig' or ev == 'Fill' or ev == 'Burn') then
		if mp:runmethods('after', 'MakeUse', wh, w) then
			return
		end
	end
	return false;
end;


VerbRemove "#Consult"
Verb {
	"#Read",
	"[|про|по]чита/ть,проч/есть",
	"в|во {noun}/пр,2 о|об|обо|про * : Consult",
	"~ о|об|обо|про * в|во {noun}/пр,2 : Consult reverse",
	"~ {noun}/вн : Consult",
}
function mp:after_Consult(s, o)
	if not o then
		mp:xaction('Exam', s)
		return
	end
	mp:message 'Consult.CONSULT'
end


VerbExtendWord {
	"#Eat",
	"[|с|об|по|раз]гры/зть,[|об]глода/ть"
}

VerbExtendWord {
	"#Attack",
	"уничтож/ить"
}

VerbExtend {
	"#Walk",
	"по {noun}/дт : Walk"
}

VerbExtendWord {
	"#Turn",
	"переверн/уть"
}

VerbExtend {
	"#Wear",
	"{noun}/вн,held на {noun}/вн : PutOn",
	"~ на {noun}/вн {noun}/вн : PutOn reverse",
}

VerbExtendWord {
	"#Drop",
	"повес/ить,остав/ить"
}

VerbExtend {
	"#Drop",
	'~ {noun}/вн,held на {noun}/пр,2: PutOn',
	"~ {noun}/вн,held в|во {noun}/пр,2,inside : Insert",
	'~ на {noun}/пр,2 {noun}/вн: PutOn reverse',
	"~ в|во {noun}/пр,2 {noun}/вн : Insert reverse",
}

VerbExtendWord { "#Insert",
	"всун/уть,установ/ить"
}

VerbExtendWord { "#SwitchOff",
	"отключ/ить"
}

VerbExtendWord { "#Pull",
	"выдвин/уть"
}

VerbExtendWord{ "#Unlock",
	"подцеп/ить,подде/ть,взлома/ть"
}

VerbExtendWord{ "#Climb",
	"забр/аться,забери/сь"
}

VerbExtendWord{ "#Tear",
	"оторвать,оторви/,оторву"
}



VerbExtend {
	"#Wave",
	"{noun}/дт : WaveHands",
	"~ {noun}/дт руками : WaveHands",
	"~ руками {noun}/дт : WaveHands",
}
function mp:after_WaveHands(w)
	if w then
		mp:message 'WaveHands.WAVE2'
	else
		mp:message 'WaveHands.WAVE'
	end
end
mp.msg.WaveHands.WAVE2 = "{#Me} глупо {#word/помахать,прш,#me} руками {#first/дт}."


VerbExtendWord {"#Fill", 
	"заправ/ить,заряд/ить,заполн/ить"}

VerbExtend {"#Fill",
	"в {noun}/вн {noun}/вн : Fill",
	"~ внутрь {noun}/рд {noun}/вн : Fill",
	"~ {noun}/вн {noun}/тв : Fill",
	"~ {noun}/вн в {noun}/вн : Fill reverse",
	"~ {noun}/вн внутрь {noun}/рд : Fill reverse",
	"~ {noun}/тв {noun}/вн : Fill reverse"
}
function mp:after_Fill(w,wh)
	if wh then
		mp:message 'Fill.FILL2'
	else
		mp:message 'Fill.FILL'
	end
end
mp.msg.Fill.FILL2 = "Наполнять {#first/вн} {#second/тв} бессмысленно."


Verb {
	"#Play",
	"игр/ать,поигр/ать,сыгр/ать",
	"Play",
	"на {noun}/пр,held : Play",
	"~ в|во {noun}/вн,held : Play",
	"~ с {noun}/тв,held : Play",
}
mp.msg.Play = {}
function mp:Play(w)
	if mp:check_touch() then
		return
	end
	if w and mp:check_held(w) then
		return
	end
	return false
end
function mp:after_Play(w)
	if not w then
		mp:message 'Play.PLAY2'
		return
	end
	mp:message 'Play.PLAY'
end
--"может"
--"знает"
mp.msg.Play.PLAY = "{#Me/им} не {#word/может,#me} играть на {#first/пр}."
mp.msg.Play.PLAY2 = "{#Me/им} не {#word/знает,#me}, на чём {#me/дт} играть."


Verb {
	"#Shoot",
	"[за|вы]стрел/ить,[|рас|по|пере|об]стрел/ять",
	"?в {noun}/вн : Shoot",
	"?в {noun}/вн из {noun}/рд,held: Shoot",
	"~ из {noun}/рд,held ?в {noun}/вн: Shoot reverse",
	"~ ?в {noun}/вн {noun}/тв,held: Shoot",
	"~ {noun}/тв,held ?в {noun}/вн: Shoot reverse"
}
mp.msg.Shoot = {}
function mp:Shoot(w, wh)
	if mp:check_touch() then
		return
	end
	if mp:check_live(w) then
		return
	end
	if wh then
		if mp:check_live(wh) then
			return
		end
		if mp:check_held(wh) then
			return
		end
	end
	return false
end
function mp:after_Shoot(w, wh)
	if wh then
		mp:message 'Shoot.SHOOT2'
	else
		mp:message 'Shoot.SHOOT'
	end
end
mp.msg.Shoot.SHOOT = "Стрелять в {#first/вн} бессмысленно."
mp.msg.Shoot.SHOOT2 = "Стрелять в {#first/вн} из {#second/рд} бессмысленно."


--[[Verb {
   "#Frotz",
   "фроц, frotz",
   "Frotz",
   "{noun}/вн,held : Frotz",
   "{noun},held : Frotz",
}

mp.msg.Frotz = {}
function mp:Frotz(w)       
    if not w then
        p "К какому объекту применить это заклинание?";
        return;
    end
    if mp:check_touch() then
        return
    end
    if mp:check_held(w) then
        p "Объект на который накладывается заклятие ФРОЦ должен находится в руках.";
        return
    end
    p("{#Me/им} произносишь заклинание ФРОЦ на {#first/пр}. {#First} начинает светится умеренным светом, достаточным, чтобы осветить любую тёмную комнату.");
    w:attr'light';
end

Verb {
   "#Rezrov",
   "резров, rezrov",
   "Rezrov",
   "{noun}/вн,held : Rezrov",
   "{noun},held : Rezrov",
}

mp.msg.Rezrov = {}
function mp:Rezrov(w)       
    if not w then
        p "Мир уже и так открыт.";
        return;
    end
    if mp:check_touch() then
        p "Объект к которому можно применить это заклинание должен находится в пределах досягаемости.";
        return
    end
    if w:has('animate') then
        p "Пожалуй, хирурги могли бы этим пользоваться, но к сожалению так это заклинание не работает.";
        return;
    end
    if w:has('open') or not w:has('openable')  then
        p "{#First/вн} не нужно открывать.";
        return;
    end
    if not w:has('locked')  then
        w:attr'open';
        p "{#First} с грохотом распахивается.";
        if w:has('container') then
            p "^";
            mp:content(w);
        end
        return;
    end

    p("{#First} тихонько открывается.");
    if w:has('container') then
        p "^";
        mp:content(w);
    end
    w:attr'open';
    w:attr'~locked';
end]]
