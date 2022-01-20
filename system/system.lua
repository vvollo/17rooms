-- свалка для нереализованных идей

game : dict {
  ["косточка/рд"] = 'косточки';
  ["косточка/дт"] = 'косточку';
  ["косточка/вн"] = 'косточку';
  ["косточка/тв"] = 'косточкой';
  ["косточка/пр"] = 'косточке';
}

obj {
	-"косточка авокадо, круглая косточка, косточка/жр";
	nam = "system_avocado_seed";
	description = function(s)
		p "Круглая косточка авокадо.";
		if not s:has'moved' then
			p "Лежит на земле под кухонным окном. Её трудно заметить в тени дома.";
		end
	end;
	init_dsc = false;
	before_Eat = function(s)
		p ("Ты разгрызаешь косточку и обнаруживаешь внутри " .. _'system_goldenkey':noun'вн' .. ".");
		remove(s);
		take('system_goldenkey');
		_"room17_door".with_key = 'system_goldenkey';
	end;
	daemon = function(s)
		if pl:have('kitchen_avocado_pieces') then
			move(s, 'room1_kryltco');
			s:attr'~moved';
			DaemonStop(s);
		end
	end;
}:attr'edible'

obj {
	-"золотой ключик, ключик";
	nam = "system_goldenkey";
	description = "Золотой ключик. Он напоминает тебе о какой-то сказке, название которой ты не можешь вспомнить.";
}

cutscene {
	nam = 'system_meet_oldman';
	text = {
		"Ты открываешь дверь и замираешь.";
		"Узкая каморка заполнена каштанами. Они лежат на полках вдоль стен и даже на полу.";
		"Посреди этого великолепия сидит старик и поедает бутерброд с авокадо.";
		"«А, это ты, ma chérie, нашла меня всё-таки. Поздравляю! А теперь уходи и не мешай мне наслаждаться трапезой».";
		"Затем он захлопывает дверь у тебя перед носом.";
		"{$fmt em|Поздравляю, вы нашли пасхалку!}";
	};
}

obj {
	-"большая красная кнопка,красная кнопка,кнопка";
	nam = "system_redbutton";
	counter = 50;
	found_in = "room5_podval";
	description = function(s)
		p "Большая красная кнопка. Притаилась в самом тёмном углу подвала. Ты бы её в жизни не нашла, если бы не знала, что она здесь.";
		if s:has'on' then
			p "Кнопка светится красным.";
		end
	end;
	after_SwitchOn = function(s)
		p "Ты нажимаешь на кнопку, она загорается красным и начинает зловеще тикать.";
		DaemonStart(s);
	end;
	after_SwitchOff= function(s)
		p "Ты нажимаешь на кнопку, она гаснет, и тиканье прекращается. Внутренний голос подсказывает тебе, что это было верное решение.";
		DaemonStop(s);
	end;
	before_Listen = function(s)
		if s:has'on' then
			p "Тик-так, тик-так, тик-так, тик-так, тик-так...";
		else
			return false
		end
	end;
	daemon = function(s)
		if not _"room16_witch":access() then
			return
		end
		s.counter = s.counter - 1;
		if s.counter < 1 then
			DaemonStop(s);
			DaemonStop 'room16_AI';
			walk 'system_explosion';
		end
	end;
}:attr'static,concealed,switchable'

cutscene {
	nam = 'system_explosion';
	text = {
		"Внезапно раздаётся оглушительно громкий взрыв.";
		"Горящие стены особняка обрушиваются тебе на голову!";
		"А, так вот что делала та кнопка в подвале.";
		"{$fmt em|Поздравляю, вы нашли пасхалку!}";
	};
	next_to = 'system_explosionE';
}

room {
	-"конец";
	nam = 'system_explosionE';
	title = "Конец";
	dsc = 'Вот и сказочке конец, тёте и тебе трындец. (Концовка №8/7)';
	noparser = true;
}

obj {
	-"пугало-друг";
	nam = "system_friend";
	daemon = function(s)
		if pl:have('gun') and pl:where() ^ 'room2_on_terrasa' and _'room2_scarecrow'.friendly then
			DaemonStop(s);
			DaemonStop 'room16_AI';
			_'room16_AI'.daemon_stage = -1;
			remove('gun');
			walk 'system_give_gun';
		end
	end;
}:attr'edible'

cutscene {
	nam = 'system_give_gun';
	text = {
		"Внезапно ты со всей чёткостью понимаешь, что должна сделать.";
		"Ты достаёшь пистолет и бросаешь его пугалу, а оно — должно быть, от порыва ветра (какого ветра?) — поворачивается и ловит его.";
		"«Благодарю тебя, прекрасная незнакомка», — раздаётся в твоей голове голос пугала.";
		"«Теперь, имея оружие, мне будет легче оборонять этот дом от злых сил, обитающих в лесу.";
		"Взамен я помогу тебе в твоей миссии.";
		"Знай, что твоя тётка находится под влиянием фрагмента тёмного зиккурата из пустыни Такла-Макан. Уничтожить камень — единственный способ её освободить.";
		"Но будь осторожна! Камень при любой возможности попытается завладеть тобой. Чтобы избежать этого, отправь камень в самое жаркое место галактики, и пусть он горит!";
		"Удачи тебе, благородная воительница!»";
		"Чёрт, этот диалог реально был, или это всё глюки от плюща?";
		"{$fmt em|Поздравляю, вы нашли пасхалку!}";
	};
	next_to = function() _'room16_AI'.daemon_stage = 4; DaemonStart 'room16_AI'; return false; end;
}

DaemonStart("system_friend");
DaemonStart("system_avocado_seed");
_"room17_door".after_Open = function(s)
	_"room17_door":attr'locked,~open';
	remove('system_goldenkey');
	walk 'system_meet_oldman';
end;
_"room1_letter".before_Turn = "На обратной стороне письма тем же почерком написано: \"Если всё же решишь зайти, то нажми красную кнопку в подвале. Так будет лучше для всех.\"";
