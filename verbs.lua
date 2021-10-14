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
	"[|с|об|по]гры/зть,[|об]глода/ть"
}

VerbExtendWord {
	"#Attack",
	"уничтож/ить"
}


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
    p("{#Me/им} произносит заклинание ФРОЦ на {#first/пр}. {#First} начал светится умеренным светом, достаточным, чтобы осветить любую тёмную комнату.");
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
