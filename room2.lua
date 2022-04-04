----[[
-- ##   ##
-- ##   ##                                            ##
-- ##   ##  ####    #####  ######  ######   #####  ##   ## ##   ## ##   ##
-- #######     ##  ##        ##    ##   ## ##   ## ##  ### ##  ##  ##  ###
-- ##   ##  #####  ##        ##    ######  ##   ## ## # ## #####   ## # ##
-- ##   ## ##  ##  ##        ##    ##      ##   ## ###  ## ##  ##  ###  ##
-- ##   ##  ######  #####    ##    ##       #####  ##   ## ##   ## ##   ##

--]]

function room2_check_uni(k)
	local _uni = _'room2_s'.uni
	if not _uni[k] then
		_uni[k] = true
		local _n = 0
		for a in pairs(_uni) do
			if _uni[a] then _n = _n + 1; end
		end
		if _n <= 2 then
			return " (Ты пару месяцев изучала " .. _'room2_s':noun('вн',k) .. ", когда была в университете, но поняла — не твоё)."
		elseif _n < 5 then
			return " (Ну, ты знаешь: университет, пара месяцев " .. _'room2_s':noun('рд',k) .. ", не твоё)."
		else
			return " (Да-да: университет — " .. _'room2_s':noun('им',k) .. " — не твоё)."
		end
	end
	return ""
end;

obj {
	-"архитектура|ботаника|история|анатомия|морская навигация";
	nam = "room2_s"; -- room2_settings
	pl_high = 0;
	has_noticed_key = false;
	been_on_high = false;
	uni = {false, false, false, false, false};
	vowels = {"а","и","о","у","э","А","И","О","У","Э"};
}

function room2_sober()
	if _'room2_s'.pl_high == 1 and not isDaemon('room16_AI') then
		p "Ты чувствуешь, что эффект от яда проходит и миру возвращаются привычные блёклые краски.";
		_'room2_s'.pl_high = 0;
	end
end;

room2_room = Class({
	status = function()
		return _'room2_s'.pl_high == 1 and "в мире ярких красок"
	end;
	['before_Exam,Open'] = function()
		return false;
	end;
	before_Listen = function(s,w)
		if not w then
			if _'room2_s'.pl_high == 0 then
				return "Минуту ты слушаешь, как шумит лес.";
			else
				return "Ты с беспокойством слушаешь, как шумит лес: тяжкие вздохи и скрипы, и зловещий шелест ветвей.";
			end
		end
		return false
	end;
	before_Taste = function()
		local _txt = "Поверь мне, это не та часть дома, где ты должна давать волю своему языку.";
		if _'room2_s'.pl_high == 1 then
			_txt = _txt .. " (Он, кстати, немного онемел)";
		end
		return _txt
	end;
	before_Default = function()
		if not mp:check_touch() then
			return false
		end
	end;
	post_Any = function(s,ev,w)
		if not w then return end;
		if ev == 'Exam' or ev == 'LookUnder' or ev == 'LookAt' then
			w:attr'seen';							-- предмет осмотрен
		if _'room2_s'.pl_high == 0 then			-- если гг не под кайфом
			w:attr'seen_before_high';			-- предмет осмотрен до кайфа
			if w:has'seen_on_high' then			-- если предмет был осмотрен под кайфом 
				w:attr'seen_after_high';		-- предмет осмотрен после кайфа
			end
		elseif _'room2_s'.pl_high == 1 then		-- если гг под кайфом
			w:attr'seen_on_high';				-- предмет осмотрен под кайфом
		end
		end
		if ev == 'Listen' and w:access() then
			w:attr'listened';						-- предмет послушан
			if _'room2_s'.pl_high == 0 then			-- если гг не под кайфом
				w:attr'listened_before_high';		-- предмет послушан до кайфа
				if w:has'listened_on_high' then		-- если предмет был послушан под кайфом 
					w:attr'listened_after_high';	-- предмет послушан после кайфа
				end
			elseif _'room2_s'.pl_high == 1 then		-- если гг под кайфом
				w:attr'listened_on_high';			-- предмет послушан под кайфом
			end
		end
		return false;
	end
}, room)

-- о/об в зависимости от первой буквы слова
function room2_about(str)
	local _vowels = _'room2_s'.vowels
	for a in pairs(_vowels) do
		if _vowels[a] == str:sub(1, 2) then return "об" end
	end
	return "о"
end;

room2_Prop = Class {
	before_Exam = function()
		return false
	end,
	before_Default = function(s, ev, w)
		p("Тебе нет нужды беспокоиться "..room2_about(s:noun'пр').." "..s:noun 'пр'..".");
	end
}:attr 'scenery'

--"оставаться"
room2_Exhibit = Class {
	['before_Exam,LookUnder,LookAt,Search'] = function(s)
		if not s:access() then
			p("Ты разглядываешь ", s:noun 'вн', " сквозь закрытые дверцы ", parent(s):noun 'рд', ":");
		end
		return false;
	end;
	before_Listen = function(s)
		if not s:access() then
			return p("Если ", s:noun 'им', " и издаёт какие-то звуки, ты их не слышишь за закрытыми дверцами ", parent(s):noun 'рд', ".");
		end
		return false;
	end;
	before_Default = function(s, ev, w)
		p(s:Noun 'им', " — экспонат. Пусть лучше {#word/оставаться,#first,нст} на месте.");
	end;
}:attr 'static';

room2_Far = Class {
	['before_Exam,WaveHands'] = function()
		return false
	end,
	before_Default = function(s, ev, w)
		p(s:Noun 'им', " слишком далеко.");
	end
}:attr 'scenery'

room2_Photo = Class {
	before_Turn = function(s)
		mp:xaction('Turn', _'room2_album')
	end;
	before_Default = function(s,ev) mp:xaction(ev, parent(s)) end;
}:attr 'concealed'

----[[
--   #####
--  ##  ##
--  ##  ##  #####  ##   ##  ####   ##   ## ##   ## ##   ##
--  ##  ## ##   ## ##  ##      ##  ##   ## ##  ### ##  ###
--  ##  ## ##   ## #####    #####  ##   ## ## # ## ## # ##
--  ##  ## ##   ## ##  ##  ##  ##  ##  ##  ###  ## ###  ##
-- ##   ##  #####  ##   ##  ######  ### ## ##   ## ##   ##
--                                       #
--]]

room2_room {
	nam = "room2_terassa",
	title = "Терраса за домом";
	dsc = function(s)
		local _forest = _'room2_s'.pl_high == 0 and "тёмного, жутковатого" or "чёрного, жуткого";
		local _scarecrow = (_'room2_s'.pl_high == 1 and _'room2_scarecrow':has'seen_on_high') and "^^Перед лесом беснуется пугало." or "";
		return "С этой стороны дом чуть менее впечатляющ, но всё такой же большой. По дорожке можно вернуться к главному входу, если пойти на запад или восток. Каменные ступеньки ведут на юг, на террасу. С другой стороны — на севере — полоска заросшего огорода отделяет тебя от " .. _forest .. " леса." .. _scarecrow
	end;
	s_to = 'room2_on_terrasa',
	u_to = 'room2_on_terrasa',
	n_to = function () p "В тот тёмный лес тебе точно не надо." end,
	e_to = function()
		room2_sober()
		return 'room1_kryltco'
	end;
	w_to = function()
		room2_sober()
		return 'room1_kryltco'
	end;
}

room2_room {
	nam = "room2_on_terrasa",
	title = "На террасе";
	onenter = function(s)
		if isDaemon('room16_AI') then
			_'room2_s'.pl_high = 1
		end
	end;
	dsc = function(s)
		local _stoneshine = isDaemon('room16_AI') and "Как только ты выбегаешь на террасу, плющ, будто бы ожив, снова жалит тебя. В мир возвращаются краски, и ты замечаешь, что мерцание камня стало особенно ярким.^^" or "";
		return _stoneshine .. "Тут тенисто и прохладно — плющ защищает пространство от зноя. В дом ведёт широкая, двустворчатая дверь. По обеим сторонам от неё стоят застеклённые шкафы с заметными табличками на них. Левый с табличкой «Саргассово море», правый — «Экспедиция в Такла-Макан».^Выход с террасы — на север, вниз по ступеням.";
	end;
	s_to = 'room2_door',
	in_to = 'room2_door',
	n_to = function(s)
		if not _'room2_s'.has_noticed_key and where(_'room2_smt_shiny') ^ 'room2_terassa' and _'room2_right_cabinet':has('open') then
			p("Сбегая по ступенькам, ты вдруг замечаешь, что на земле под плющом что-то блестит.");
			_'room2_s'.has_noticed_key = true;
			enable('room2_smt_shiny');
		end
		return 'room2_terassa';
	end;
	d_to = function(s) mp:xaction("Walk", _'@n_to') end;
	out_to = function(s) mp:xaction("Walk", _'@n_to') end;
}

door {
	-"дверь";
	nam = "room2_door";
	door_to = function()
		room2_sober()
		if not _'room2_black_rock':where() ^ 'room2_right_cabinet' then
			DaemonStop 'room16_AI';
			return 'room12_cutsceneStone'
		end;
		return 'room12_gostinnaya'
	end;
	when_locked = [[Здесь есть закрытая дверь.]];
	when_open = [[Дверь открыта.]];
	with_key = 'emptyroom';
	before_Unlock = function(s, w)
		if w ^ 'bigkey' then
			return "Хм, столько приключений, чтобы добыть " .. _'bigkey':noun'вн' .. ", а он к этой двери не подходит."
		end
		return false
	end;
	before_Push = "Похоже, сила здесь не поможет. Нужен подходящий ключ.";
	before_Attack = "Ты колотишь в дверь кулаком, но, как и предполагала — никто не открывает.";
	found_in = { 'room2_on_terrasa' };
}:attr 'scenery,openable,lockable,locked';

room2_Prop {
	-"дорожка,дорога,тропинка|красные кирпичи,красные,кирпичи,пучки травы,пучки,трещинки/но";
	nam = "room2_walk";	
	description = function(s)
		local _txt = _'room2_s'.pl_high == 0 and "" or " Ты на несколько минут замираешь, разглядывая узоры трещинок на разных кирпичах, их отличия по высоте, степень выщербленности, оттенки цвета и тому подобные вещи."
		return "Красные кирпичи, утопленные в землю. Между ними пробиваются пучки нетоптаной травы. Дорожка обегает вокруг дома на западе и на востоке.".._txt
	end;
	before_Walk = function(s) mp:xaction("Walk", _'@w_to') end;
	found_in = {'room2_terassa'};
}

room2_Prop {
	-"терраса|дом,фасад";
	nam = "room2_terrasa_obj";
	description = function(s)
		local _txt = s:hasnt'seen' and "(конечно же!) " or "";
		if here() ^ "room2_terassa" then
			return "Широкая тенистая терраса занимает весь фасад дома. Её деревянные перила окрашены в голубой " .. _txt .. "цвет, однако, их почти не видно за густыми зарослями плюща, что опутал все столбы и добрался до крыши. Вход на террасу — на юге, по каменным ступенькам."
		else
			return _'room2_on_terrasa'.dsc
		end
	end;
	['before_Enter,Climb'] = function(s)
		if here() ^ "room2_terassa" then
			walk 'room2_on_terrasa'
		else
			mp:xaction("Walk", _"@s_to")
		end
	end;
	['before_Exit,GetOff'] = function(s)
		if here() ^ "room2_on_terrasa" then
			mp:xaction("Walk", _"@n_to")
		else
			return false
		end
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}:attr 'supporter';

room2_Prop {
	-"ступеньки,ступени";
	nam = "room2_steps";
	description = function(s)
		local _txt = "Широкие каменные ступеньки, немного стёртые посередине, ";
		if here() ^ "room2_terassa" then
			return _txt .. "поднимаются на террасу."
		else
			return _txt .. "сбегают с террасы вниз, к дорожке."
		end
	end;
	before_Walk = function(s)
		if here() ^ "room2_terassa" then
			mp:xaction("Walk", _"@s_to")
		else
			mp:xaction("Walk", _"@n_to")
		end

	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}

room2_Prop {
	-"перила,столбики";
	nam = "room2_handrails";
	description = function(s)
		if here() ^ "room2_terassa" then
			return "Перила едва видны, почти полностью скрытые листьями плюща."
		else
			local _txt = room2_check_uni(1);
			return "С этой стороны видно, что столбики перил — искусная зодческая работа в псевдо-русском стиле." .. _txt
		end
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}

obj {
	-"плющ|листья плюща,листья,прожилки,стебли";
	nam = "room2_ivy";
	seen_empty = false;
	description = function(s)
		local _study = room2_check_uni(2);
		local _txt = "";
		if _'room2_s'.pl_high == 0 then
			if here() ^ "room2_terassa" then
				_txt = "Красивый, широколистный плющ, опутавший всю террасу. С виду — обычный Hedéra hélix." .. _study .. " Но тебя настораживает красноватый отлив его листьев.";
				if _'room2_s'.has_noticed_key and _'room2_smt_shiny':access() then
					_txt = _txt .. "^^Под плющом всё блестит какой-то предмет."
				end
			else
				_txt = "Плющ опутал все перила террасы, по столбам поднялся к самой крыше, надёжно укрыв пространство террасы своими большими листьями от взглядов с улицы (не то чтобы было кому подглядывать). Очень похожий на Hedéra hélix." .. _study .. " Однако, снизу его листья покрыты красными прожилками, а про такое ты не читала."
			end
		else
			_txt = "Вездесущий плющ, опутавший всю террасу своими стеблями. С виду — обычный Hedéra hélix." .. _study .. " Но ты уже на своём опыте поняла, что это не он. Какая-то иноземная разновидность, ядовитая и коварная. Его большие красноватые листья дрожат на ветру (которого нет).";
		end
		return _txt;
	end;
	['before_LookUnder'] = function(s)
		if here() ^ "room2_on_terrasa" then
			return "Отсюда не видно, нужно спуститься с террасы."
		else
			if _'room2_smt_shiny':access() then 
				if not _'room2_s'.has_noticed_key then 
					p ("На земле под плющом ничего нет. Ты в этом абсолютно уверена.");
					s.seen_empty = true;
				else
					mp:xaction('Exam',_'room2_smt_shiny')
				end
			else
				return "Больше под этим плющом ничего нет."
			end
		end
	end;
	['before_Take,Touch,Rub'] = function(s)
		if not _'room2_s'.been_on_high then
			return "Нет уж. Вдруг он ядовитый, а у тебя обнаружится аллергическая реакция, и что тогда? Аптеки поблизости ты что-то не помнишь.";
		else
			if _'room2_s'.pl_high == 0 then
				_'room2_s'.pl_high = 1
				return "Сначала ты медлишь: это уже похоже на зависимость, но потом — была не была — суёшь руку прямо в заросли плюща. И тут же выдёргиваешь, почувствовав жжение. Яркие краски, к твоему удовольствию, возвращаются.";
			else
				return "Ты ещё чувствуешь действие яда на своё сознание, дополнительной дозы тебе сейчас не нужно.";
			end
		end
	end;
	['before_Tear,Cut,Attack'] = function(s)
		if not _'room2_s'.been_on_high then
			return "Нет уж. Вдруг он ядовитый, а у тебя обнаружится аллергическая реакция, и что тогда? Аптеки поблизости ты что-то не помнишь.";
		else
			return "Тебе как-то не хочется вредить плющу, учитывая, на что он способен.";
		end
	end;
	before_Climb = function(s)
		local _txt = _'room2_s'.been_on_high == true and " К тому же он ядовитый." or ""
		return "Было бы интересно, конечно, прямо как в кино. Но, к сожалению, его стебли недостаточно крепкие и не выдержат твоего веса.".._txt
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}:attr 'scenery':dict {
	["листья/вн"] = "листья";
	["листья/рд"] = "листьев";
	["листья/дт"] = "листьям";
	["листья/тв"] = "листьями";
	["листья/пр"] = "листьях";
};

obj {
	-"что-то блестящее,что-то,нечто,блестящее,монет*,ключ*,кулон*,предмет*";
	nam = "room2_smt_shiny";
	dsc = "На земле под плющом что-то блестит.";
	description = function(s)
		local _txt = s:has'seen' and " В принципе, ты видишь прогалины между листьев, где бы ты смогла протянуть руку к предмету, не задев плюща." or ""
		local _wtf = _'room2_ivy'.seen_empty and "^^Так, стоп, ты же помнишь, что под плющом ничего не было! Неужели ты такая невнимательная?" or ""
		return "Ты никак не можешь разобрать, что же это такое — тебе мешают листья плюща. Монета? Ключ? Кулон?".._txt.._wtf
	end;
	before_Take = function(s)
		move('bigkey', pl);
		remove(s);
		_'room2_s'.has_noticed_key = true;
		_'room2_s'.pl_high = 1;
		_'room2_s'.been_on_high = true;
		walkin('room2_took_key');
		if (s.once) then
    		  mp.score=mp.score+1
    		end
	end;
	found_in = {'room2_terassa'};
}:disable()

room2_Prop {
	-"земля|ленинградский суглинок,суглинок,ленинградский";
	description = function(s) 
		return _'room2_s'.pl_high == 0 and "Земля как земля, обычный ленинградский суглинок, ничего особенного." or "Твой взгляд останавливается на земле и ты несколько минут думаешь обо всех этих эпохальных геологических процессах, что закончились этим скучным ленинградским суглинком."
	end;
	['before_Exam,Search'] = function(s)
		if _'room2_smt_shiny':access() and _'room2_s'.has_noticed_key then
			mp:xaction('Exam',_'room2_smt_shiny')
		else
			return false;
		end;
	end;
	before_Eat = "Тебе что, два года?";
	found_in = {'room2_terassa'};
}:attr 'scenery';

cutscene {
	nam = 'room2_took_key';
	text = {
		"Ты осторожно, стараясь не касаться ни листьев, ни стеблей плюща, протягиваешь руку к тому месту, где блестит таинственный предмет.";
		"Двумя пальцами подцепляешь его, чувствуя холод металла. И так же осторожно тянешь руку обратно — из красноватых зарослей плюща.";
		"Ты уже почти вынула руку, когда происходит странное — один из листьев качается на ветру (но ветра же нет!) и всей поверхностью липнет к твоему запястью.";
		"Зашипев от боли, ты выдёргиваешь руку и разглядываешь обожжённое запястье, но не видишь никаких следов.";
		"Единственное, что изменилось — краски окружающего мира становятся как-то насыщеннее, ярче. Хм.";
		"И со стороны шкафов на террасе ты краем глаза замечаешь мерцание, правда, недолгое.";
		"Зато разжав кулак, ты видишь, что достала " .. _'bigkey':noun'вн' .. ".";
	};
}

room2_Prop {
	-"шкафы";
	description = "Застеклённые шкафы с хранящимися в них экспонатами: в левом — про тайны Саргассова моря, в правом — про секретную советскую экспедицию в пустыню Такла-Макан.";
	before_Open = "Здесь есть правый шкаф и левый шкаф.";
	found_in = {'room2_on_terrasa'};
}:attr 'scenery';

room2_Prop {
	-"экспонаты,предметы";
	description = "Лучше рассматривать их поближе, что в левом, что в правом шкафах.";
	found_in = {'room2_on_terrasa'};
}:attr 'scenery';

----[[
--   #####
--  ##  ##                            ##                                 #
--  ##  ##  #####  #####   ##   ## ##   ##    ## # ## ##   ##  ####    #####
--  ##  ## ##   ## ##  ##  ##   ## ##  ###    ## # ## ##  ##      ##  ## # ##
--  ##  ## ######  ######  ####  # ## # ##    ## # ## #####    #####  ## # ##
--  ##  ## ##      ##   ## ##  # # ###  ##    ## # ## ##  ##  ##  ##   #####
-- ##   ##  #####  ######  ####  # ##   ##    ####### ##   ##  ######    #

--]]

obj {
	word = -"левый шкаф, шкаф, левый/но|саргассы/мн,но",
	nam = 'room2_left_cabinet',
	description = function(s)
		local _txt = s:has'open' and "открытый" or "закрытый"
		local _mary = _'room2_celeste':hasnt'seen' and "парусника" or "«Марии Селесты»";
		return "Слева от двери стоит ".._txt.." шкаф, названный «Саргассово море». Судя по описанию на табличке в нём представлены экспонаты, так или иначе связанные с тайнами Саргассова моря и Бермудского треугольника. Среди всего содержимого шкафа твоё внимание привлекают: большая морская раковина, масштабная модель ".._mary.." и компас.";
	end;
	before_LetIn = "Не нужно в шкаф ничего совать — всё необходимое в нём уже есть.";
	found_in = {'room2_on_terrasa'};
	obj = {'room2_compass','room2_shell','room2_celeste',
		obj {
			-"табличка левого шкафа,левая табличка,левая,табличка/но";
			description = "Вверху большими буквами: «Саргассово море» и ниже меньшим шрифтом: «Этот район Атлантического океана известен с давних пор. Ещё викинги рассказывали друг другу истории о гиблом „море“, которое лучше огибать с севера. Когда наладилась коммуникация между Старым и Новым Светом, историй о чудовищах, необъяснимых явлениях, о таинственных исчезновениях стало в разы больше. И до самых наших дней учёные не могут объяснить некоторые из них. Здесь, в данной экспозиции вы найдёте любопытные свидетельства того, что не всё ещё так просто с этим загадочным местом — Саргассовым морем».";
			before_Take = "Она закреплена над шкафом и тебе её не достать. Да и зачем она тебе?";
		}:attr'static'
	};
}:attr 'scenery,container,transparent,openable,~animate';
room2_Prop {
	-"дверцы левого шкафа,левые дверцы,дверцы,левые";
	description = function(s)
		if _'room2_left_cabinet':has'open' then
			return false
		end
		p("Ты разглядываешь содержимое левого шкафа сквозь стеклянные дверцы:^^");
		mp:content(_'room2_left_cabinet');
		return;
	end;
	before_Open = function(s) mp:xaction("Open", _'room2_left_cabinet') end;
	before_Close = function(s) mp:xaction("Close", _'room2_left_cabinet') end;
	found_in = {'room2_on_terrasa'};
}

room2_Exhibit {
	word = function(s)
		return s:has'seen' and -"компáс,компас|картушка" or -"компас,компáс";
	end;
	nam = "room2_compass",
	description = function(s)
		local _study = room2_check_uni(5);
		if _'room2_s'.pl_high == 0 then
			if s:hasnt'seen_on_high' then
				local _txt = s:hasnt'seen' and " («компáс», мысленно поправляешь ты себя)" or "";
				local _needle = s:hasnt'seen' and " (Картушка — это та часть морского компáса, которая поворачивается вместо стрелки у сухопутного компаса)." or "";
				return "Старинный морской " .. s:noun('им') .. _txt .. ". Медный корпус с нанесёнными на него румбами, пожелтевшая картушка повёрнута красной стрелкой Норда в сторону леса." .. _needle .. _study;
			else
				return "Теперь с компáсом всё в порядке — картушка замерла и своей красной «N» указывает в сторону леса."
			end
		else
			if s:hasnt'seen_on_high' then
				local _txt = s:hasnt'seen' and " («компáсом», мысленно поправляешь ты себя)" or "";
				return "Что-то не так с этим " .. s:noun('тв') .. _txt .. " — его картушка почему-то безостановочно вращается. Ты никогда такого не видела."
			else
				if s:hasnt'seen_after_high' then
					return "Картушка компáса всё вращается."
				else
					return "Картушка компáса опять вращается!"
				end
			end
		end
	end;
	before_Take = function(s)
		local _txt = _'room2_s'.pl_high == 0 and "" or " (особенно, если его картушка вращается как сумасшедшая)";
		return "Тебе с твоей врождённой способностью ориентироваться по сторонам света дополнительное приспособление не нужно" .. _txt .. ".";
	end;
}:dict{
	["компáс/мр,но,С"] = {"компáс/им", "компáсы/им,мн", "компáс/вн",
									 "компáсы/вн,мн", "компáса/рд", "компáсов/рд,мн",
									 "компáсу/дт", "компáсам/дт,мн", "компáсом/тв",
									 "компáсами/тв,мн", "компáсе/пр", "компáсах/пр,мн"}
}

room2_Exhibit {
	-"раковина,ракушка,морская";
	nam = "room2_shell";
	description = function (s)
		if s:hasnt'listened_on_high' then
			local _txt = s:hasnt'listened' and " Интересно, если её послушать, будет ли слышно море?" or ""
			return "Большая и очень красивая раковина, снаружи покрытая множеством разных отростков, внутри — гладкая и перламутровая.".._txt
		else
			if _'room2_s'.pl_high == 0 then
				return "Ладно, в прошлый раз на тебя что-то нашло и тебе почудилось всякое, но большая перламутровая раковина уже не кажется тебе такой же красивой."
			else
				return "Раковина всё такая же большая и красивая, но ты боишься оторвать взгляд от её внутренней поверхности — вдруг оттуда покажется то, что там скреблось."
			end
		end
	end;
	before_Listen = function (s)
		if not s:access() then
			return p("Если ", s:noun 'им', " и издаёт какие-то звуки, ты их не слышишь за закрытыми дверцами ", parent(s):noun 'рд', ".");
		end
		if s:hasnt'listened_on_high' then
			local _txt = room2_check_uni(4);
			if _'room2_s'.pl_high == 0 then
				return "Ты аккуратно поднимаешь довольно тяжёлую раковину и прикладываешь её к уху. И тут же слышишь шум прибоя. Который, как ты, конечно, знаешь — всего лишь шум твоего собственного сердцебиения и тока крови." .. _txt .. " Наслушавшись ненастоящего моря, ты возвращаешь раковину обратно — экспонат всё-таки.";
			elseif _'room2_s'.pl_high == 1 then
				return "Ты аккуратно поднимаешь тяжёлую раковину и прикладываешь её к уху. Сначала ты слышишь шум прибоя. Который, как ты, конечно, знаешь — всего лишь шум твоего собственного сердцебиения и тока крови." .. _txt .. "^Ты задерживаешь раковину у уха и, кажется, за прибоем начинаешь слышать что-то ещё. Песню. Женский голос поёт сладкозвучно и очень печально, наверное, о потерянной любви, потому что ты не знаешь других причин петь так грустно и так красиво. Как вдруг песня обрывается и голос гаркает:^— ¿Quién está ahí?^А потом из глубин раковины доносится скребущийся звук. Всё ближе и громче. Ты отдёргиваешь от себя раковину и поспешно возвращаешь её на полку.";
			end
		else
			if _'room2_s'.pl_high == 0 then
				return "Возможно в прошлый раз тебе и показалось, однако, всякое желание подносить эту раковину к своему уху у тебя отбило напрочь."
			else
				return "Ты ни за что не притронешься к этой раковине!"
			end
		end
	end;
	before_Open = "Нет, это другая раковина, не та, которая из двух створок и открывается, а та, которая завитая спиралью и в ней ещё можно слушать море. Ты что, не видишь?";
	before_Take = function(s) mp:xaction("Listen", s) end;
}

-- нужно повторение словарных слов, потому что иначе не воспринимает:
--"модель,корабль,паруса"
room2_Exhibit {
	word = function(s)
		local _model = s:has'seen' and "модель «Марии Селесты»" or "модель парусника";
		local _wrd = _'room2_s'.pl_high == 0 and "" or "диорама,кракен*,пожар*,чудовище*,щупальца*,доски*";
		return -"".._model..",модель,мария,селеста,бригантина,палуба,корма,рубка,мачта,mary celeste,mary,celeste,название*/жр,нд|корабль,парусник,такелаж|паруса,надстройки,якоря,якорьки,механизмы/мн|".._wrd.."/жр,нд";
	end;
	nam = "room2_celeste";
	description = function (s)
		if _'room2_s'.pl_high == 0 then
			if s:hasnt'seen_on_high' then
				return "Красивая двухмачтовая бригантина, скрупулёзно воссозданная в масштабе модели: путаница такелажа, белоснежные паруса, палуба с различными надстройками и механизмами, крошечные якорьки. На корме, под окнами капитанской рубки — название «MARY CELESTE».";
			else
				return "Это вновь та же аккуратная бригантина без признаков разрушения. С тщательно воссозданными парусами, такелажем, якорьками. Название вновь полное: «MARY CELESTE»."
			end
		else
			local _txt = s:has'seen_before_high' and " уже" or ""
			return "С удивлением ты наблюдаешь".._txt.." не просто модель, а целую живую диораму: парусник «Мария Селеста», атакованный огромным кракеном. Паруса оборваны и висят клочьями с рей, задняя мачта сломана посредине и свисает с правого борта, щупальца чудовища опутали всю верхнюю палубу и через люки запустились на нижние. Дверь в капитанскую рубку заколочена досками. На носу пожар. В названии на корме не хватает нескольких букв."
		end
	end
}:dict {
	["кракен/вн"] = "кракена";
	["кракен/рд"] = "кракена";
	["кракен/дт"] = "кракену";
	["кракен/тв"] = "кракеном";
	["кракен/пр"] = "кракене";
	["диорама/вн"] = "диораму";
	["диорама/рд"] = "диорамы";
	["диорама/дт"] = "диораме";
	["диорама/тв"] = "диорамой";
	["диорама/пр"] = "диораме";
}

----[[
-- #######
-- ##   ##                                    ##                                 #
-- ##   ## ######   ####   #####   ##   ## ##   ##    ## # ## ##   ##  ####    #####
-- ##   ## ##   ##     ##  ##  ##  ##   ## ##  ###    ## # ## ##  ##      ##  ## # ##
-- ##   ## ######   #####  ######  ####  # ## # ##    ## # ## #####    #####  ## # ##
-- ##   ## ##      ##  ##  ##   ## ##  # # ###  ##    ## # ## ##  ##  ##  ##   #####
-- ##   ## ##       ###### ######  ####  # ##   ##    ####### ##   ##  ######    #

--]]

obj {
	-"правый шкаф, шкаф, правый, Такла-Макан,экспедиц*/но|дверцы правого шкафа, дверцы",
	nam = 'room2_right_cabinet',
	description = function(s)
		local _txt = s:has'open' and "открытый" or "закрытый"
		local _stonehere = _'room2_black_rock':where() ^ s and "" or " (которого здесь уже нет)"
		return "Справа от двери — ".._txt.." шкаф с табличкой «Экспедиция в Такла-Макан». Описание гласит, что экспонаты в нём связаны с секретной советской экспедицией 1946 года на северо-запад Китая. Больше всего тебя заинтересовали: карта с маршрутом экспедиции, альбом с фотографиями и обломок чёрного камня" .. _stonehere .. "."
	end;
	before_LetIn = "Не нужно в шкаф ничего совать — всё необходимое в нём уже есть.";
	before_Open = function(s)
		if s:has('~open') then
			s:attr('open');
			mp.score=mp.score+1;
			walkin('room2_opened_cabinet');
		else
			return false;
		end;
	end;
	before_Close = function(s)
		if s:has('open') then
			return "Странно, но ты не можешь закрыть шкаф. Дверцу, должно быть, заклинило.";
		else
			return false;
		end;
	end;
	found_in = {'room2_on_terrasa'};
	obj = {'room2_black_rock','room2_album','room2_map',
		obj {
			-"табличка правого шкафа,правая табличка,правая,табличка/но";
			description = "Вверху большими буквами: «Экспедиция в Такла-Макан» и ниже меньшим шрифтом: «Когда большая и страшная война закончилась, победители к своему удивлению обнаружили у себя на руках множество загадочных и малообъяснимых свидетельств, полученных Третьим Рейхом во время недолгой активности оккультного общества „Аненербе“. Страна восстанавливалась и археология не была одной из приоритетных наук, но тем не менее, наркомат просвещения организовал целую экспедицию из профессорского и студенческого состава кафедры исторического факультета МГУ в далёкий и глухой уголок Китая — пустыню Такла-Макан. Неизвестно, что же послужило толчком для кабинетных начальников пойти на такие расходы и каковы были результаты, так как всё, что связано с этой экспедицией, было тщательно засекречено. Однако, предметы данной экспозиции помогут пролить немного света на эту тайну».";
			before_Take = "Она закреплена над шкафом и тебе её не достать. Да и зачем она тебе?";
		}:attr'static'
	};
}:attr 'scenery,container,transparent,openable';
room2_Prop {
	-"дверцы правого шкафа,правые дверцы,дверцы,правые";
	description = function(s)
		if _'room2_right_cabinet':has'open' then
			return false
		end
		p("Ты разглядываешь содержимое правого шкафа сквозь стеклянные дверцы:^^");
		mp:content(_'room2_right_cabinet');
		return;
	end;
	before_Open = function(s) mp:xaction("Open", _'room2_right_cabinet') end;
	before_Close = function(s) mp:xaction("Close", _'room2_right_cabinet') end;
	found_in = {'room2_on_terrasa'};
}


cutscene {
	nam = 'room2_opened_cabinet';
	text = {
		"Ты открываешь шкаф.";
		"Внезапно лежащий внутри обломок камня сверкает ярким огнём.";
		"Или нет, просто показалось?";
		"К тебе приходит осознание чего-то непоправимого. По спине бегут мурашки.";
		"Настя, да что на тебя нашло? Ничего же не случилось. Возьми себя в руки!";
	};
}

room2_Exhibit {
	-"обломок чёрного камня,кусок,чёрный,камень,кусок,обломок";
	nam = "room2_black_rock";
	dsc = "На полу лежит обломок камня и светится красным пульсирующим светом.";
	description = function(s)
		if not s:where() ^ 'room2_right_cabinet' then
			return "Этот камень -- чистое Зло! Его нужно уничтожить!"
		elseif _'room2_s'.pl_high == 0 then
			return "Небольшой — с твой кулак — обломок совершенно чёрного камня непонятной породы. Мог бы быть углём, однако, в отличие от антрацитов совершенно не отражает света."
		else
			if _'room2_album'.page == 6 then 
				return "Внутри чёрного обломка пульсирует неяркий красный свет."
			elseif _'room2_album'.page == 7 then 
				return "Обломок почти светится изнутри красным пульсирующим светом!"
			elseif _'room2_album'.page == 8 then 
				return "Огонь внутри обломка уже не пульсирует, а просто светит сквозь, казалось бы, непроницаемые стенки. Кажется, от него исходят едва слышные вибрации."
			else
				return "С ходу незаметно, но если приглядеться — внутри обломка как будто пульсирует очень слабый свет."
			end
		end
	end;
	before_Listen = function(s)
		if not s:access() then
			return p("Если ", s:noun 'им', " и издаёт какие-то звуки, ты их не слышишь за закрытыми дверцами ", parent(s):noun 'рд', ".");
		end
		if _'room2_s'.pl_high == 1 and _'room2_album'.page == 8 then 
			return "Ты слышишь едва заметный, на самой границе слышимости, зуд, волнами расходящийся от камня.";
		end
		return false;
	end;
	before_Touch = "Ты сама не понимаешь почему, но тебе не хочется к нему прикасаться.";
	before_Take = function(s)
		if not _'room2_s'.been_on_high then
			p(s:Noun 'им', " — экспонат. Пусть лучше {#word/оставаться,#first,нст} на месте.");
			return true;
		end;
		if not s:where() ^ 'room2_right_cabinet' then
			return false;
		end;
		s:destroyEvilStone();
	end;
	["before_Cut,Tear,Attack,ThrownAt"] = function(s, w)
		if not _'room2_s'.been_on_high then
			return false;
		end;
		if w == nil then
			p "Чем?!";
			return true;
		end;
		if mp:check_held(w) then
			return
		end;
		if w ~= nil then
			if w ^ "kitchen_knife" then
				p "Максимум, чего ты добьёшься -- сломаешь нож.";
			elseif w ^ "dagger" then
				s:destroyEvilStone(w);
			else
				p "Инструмент явно не подходящий.";
			end;
		end;
	end;
	before_Shoot = function(s, w)
		if not _'room2_s'.been_on_high then
			return false;
		end;
		if not w and pl:have('gun') then
			w = _'gun';
		end
		if w == nil then
			p "Из чего?!";
			return true;
		end;
		if mp:check_held(w) then
			return
		end;
		if w ~= nil then
			if w ^ "gun" then
				s:destroyEvilStone(w);
			else
				p "Это явно не огнестрельное оружие.";
			end;
		end;
	end;
	destroyEvilStone = function(s, w)
		if not isDaemon('room16_AI') then
			p [[Ты чувствуешь в камне Зло и хочешь его уничтожить. Но твоя рука дрожит и пальцы не слушаются.^
			В мерцании камня тебе чудится злорадство.]];
		elseif not w then
			p "Ты хватаешь камень и охаешь. Он как будто раскалённый! Тётка, уже собиравшаяся наброситься на тебя, слегка отшатывается. Однако, не удержав камень в руках, ты его роняешь, и он залетает в дом через открытую дверь.";
			move(s, 'room12_gostinnaya');
			s:attr'~static';
			_'room16_AI'.daemon_stage = 4;
			_'room16_AI'.daemon_dop = 1;
			mp.score=mp.score+1;
		else
			DaemonStop 'room16_AI';
			walk 'ending_evil';
		end;
	end;
	before_Default = function(s, ev, w)
		if not _'room2_s'.been_on_high then
			p(s:Noun 'им', " — экспонат. Пусть лучше {#word/оставаться,#first,нст} на месте.");
			return true;
		end;
		return false;
	end;
}



room2_Exhibit {
	-"альбом с фотографиями,альбом/мр,ед|фотографии,фотки|печать,обложка,книга";
	nam = "room2_album";
	page = 1;
	description = function(s)
		if s:hasnt'open' then
			return "Потёртый кожаный альбом с прямоугольной печатью «СОВСЕК» посередине красной обложки. Закрыт."
		else
			return "Раскрытый альбом с пожелтевшей фотографией забытой экспедиции:^"..s.obj[s.page].pageDsc()
		end
	end;
	before_Open = function(s)
		if not s:access() then
			return false;
		end
		if s:hasnt'open' then
			s:attr'open';
			return "Ты осторожно открываешь альбом, явив свету пожелтевшую фотографию семидесятипятилетней давности:^"..s.obj[s.page].pageDsc().."^^Похоже, ты можешь перевернуть страницу.";
		end
		return false;
	end;
	before_Close = function(s)
		return false;
	end;
	before_Turn = function(s)
		if not s:access() then
			return false;
		end
		if s:hasnt'open' then
			return "В закрытом альбоме страницы переворачивать не получится."
		end
		s.page = s.page + 1
		if s.page > table.getn(s.obj) then
			s.page = 1
			return "Похоже, эта страница была последней. Ты перелистываешь в самое начало:^"..s.obj[s.page].pageDsc();
		else
			return "Ты переворачиваешь страницу альбома:^"..s.obj[s.page].pageDsc();
		end
	end;
	['post_Exam,Open,Turn,LookUnder,LookAt'] = function(s)
		local w = s.obj[s.page]
		w:attr'seen';							-- фото осмотрено
		if _'room2_s'.pl_high == 0 then			-- если гг не под кайфом
			w:attr'seen_before_high';			-- фото осмотрено до кайфа
			if w:has'seen_on_high' then			-- если фото был осмотрено под кайфом 
				w:attr'seen_after_high';		-- фото осмотрено после кайфа
			end
		elseif _'room2_s'.pl_high == 1 then		-- если гг под кайфом
			w:attr'seen_on_high';				-- фото осмотрено под кайфом
		end
		return false;
	end;
	obj = {
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_1";
			pageDsc = function()
				local _culman = ""
				local _members = ""
				local _stone = _'room2_album_6'.has_seen_light and (_'room2_s'.pl_high == 1) and "^^Пульсация света в камне возвращается к едва различимому красноватому отсвету. Как будто камень реагирует на то, какая фотография сейчас открыта." or ""
				if _'room2_s'.pl_high == 0 then
					_members = "Кто-то в костюме и в лихо сдвинутой кепке, кто-то в гимнастёрке с медалью, кто-то в невзрачной робе и с короткой стрижкой. Почти никого старше тридцати. "
				else
					_members = "Там, где должны быть лица, фото расцарапано до белой основы. "
				end
				if _'room2_s'.pl_high == 1 and _'room2_album_7':has'seen' then
					_culman = "На фоне — кульман, на котором расчерчен зловещий зиккурат."
				else
					_culman = "На фоне — кульман со схемами и картами, впрочем, качество фотографии не позволяет разглядеть деталей."
				end
				return "    Фотография восьмерых участников экспедиции на кафедре исторического факультета МГУ. ".._members.._culman.._stone;
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_2";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					local _zundapp = ""
					if _'room2_album_3':hasnt'seen' then
						_zundapp = "В полумраке на заднем плане видны мотоциклы с колясками, но не в фокусе, поэтому непонятно, какой марки."
					else
						_zundapp = "В полумраке на заднем плане видны «Цундаппы» с колясками, но не в фокусе, поэтому деталей не разобрать."
					end
					return "    Фотография гаража: на переднем плане — «Студебеккер», подготавливаемый к пустынному пробегу. Жёсткий кунг обтянут светлой тканью, на крышу кабины установлен деревянный щит от нагрева, в открытом капоте видны большие цилиндры воздушных фильтров, установлены дополнительные противотуманные фары. ".._zundapp;
				else
					return "    Фотография гаража: на переднем плане — «Студебеккер», перед подготовкой к пустынному пробегу. Видно, что машина в своём недавнем прошлом — фронтовая. Кунг насквозь прошит пулеметными очередями, кабина изнутри — в багровых пятнах, фары разбиты. В полумраке на заднем плане — другая техника в схожем состоянии."
				end
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_3";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					if _'room2_album_3':hasnt'seen' then
						return "    Фотография железнодорожного состава: на платформах друг за другом закреплены два «Студебеккера» и три мотоцикла. По характерной раме ты, наконец, понимаешь, что это за марка: «Цундаппы». Само собой.";
					else
						return "    Фотография железнодорожного состава: на платформах друг за другом закреплены два «Студебеккера» и три мотоцикла с характерными рамами — трофейные «Цундаппы»."
					end
				else
					return "    Фотография железнодорожного состава и путей перед ним: на платформах закреплены и полускрыты под брезентом «Студебеккеры» и трофейные «Цундаппы».^Участок путей перед локомотивом неисправен — снимок застал группу пленных в изношенных немецких шинелях за укладкой новых шпал, пропитанных чёрным креозотом."
				end
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_4";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					return "    Фотография «Цундаппа» на фоне минаретов и большого портала, покрытого характерным орнаментом, под которым толпится большая толпа в полосатых халатах и чалмах. Хотя фото и чёрно-белое, ты уверена, что портал облицован керамикой глубокого лазоревого цвета. В углу подпись чернилами: «Самарканд».";
				else
					return "    Фотография «Цундаппа» на фоне средневековых минаретов и большого портала, кое-где покрытого характерным орнаментом. Местность безлюдная и заброшенная. Керамическое покрытие сооружений давно осыпалось, их стены постепенно разрушаются и покрываются пятнами. В углу подпись чернилами: «Самарканд»."
				end
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_5";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					return "    Фотография сгрудившихся участников экспедиции вокруг открытого капота одного из «Студебеккеров». Чуть правее один из группы (начальник?) общается с двумя местными, невысокими, в халатах и тюбетейках. На фоне выстроились в ряд разномастные глинобитные домики. В углу теми же чернилами и тем же почерком: «Кашгар».";
				else
					return "    Фотография сгрудившихся участников экспедиции вокруг тела одного из своих. Чуть правее начальник группы направляет длинный «ТТ» на двух местных, невысоких, в халатах и тюбетейках, сжимающих ножи и ощерившихся. На фоне выстроились в ряд разномастные глинобитные домики. В углу теми же чернилами и тем же почерком: «Кашгар»."
				end
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_6";
			has_seen_light = false;
			pageDsc = function()
				local _dot = ""
				local _stone = ""
				if _'room2_s'.pl_high == 0 then
					_dot = "светящаяся точка сигареты"
				else
					_'room2_album_6'.has_seen_light = true
					_dot = "две светящиеся точки глаз"
					_stone = "^^Ты замечаешь, как в чёрном обломке пульсация света становится всё заметней.";
				end
				return "    Ночное фото «Студебеккера» на фоне засвеченной вспышкой пустыни. Трое участников в свете фар откапывают перед грузовиком две колеи. В темноте кабины — ".._dot..". Фонтан песка, сорвавшийся с одной из лопат, навсегда застыл в свете вспышки.".._stone;
			end
		};
		room2_Photo {
			-"фотография|страница|фото|зиккурат";
			nam = "room2_album_7";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					return "    На переднем плане фотографии — оба грузовика и мотоциклы. Все члены экспедиции стоят у техники, спиной к камере. Они смотрят вдаль, туда, где посреди плоской пустыни возвышается огромный чёрный зиккурат.^Многоярусная пирамида с длинной лестницей, ведущей к самой вершине. Все линии геометрически чёткие и точные, совсем не тронутые временем. Тебе почему-то становится не по себе от одного взгляда на это угольно-чёрное сооружение.";
				else
					return "    На переднем плане фотографии никого нет, ни техники, ни людей. Только у горизонта, над плоской пустыней возвышается огромный чёрный зиккурат.^Многоярусная пирамида с длинной лестницей, ведущей к самой вершине. Все линии геометрически чёткие и точные, совсем не тронутые временем. Даже здесь, в тысячах и тысячах километрах от этого угольно-чёрного монумента, ты чувствуешь исходящую от него угрозу.^^Свет, пульсирующий в камне становится ещё ярче."
				end
			end
		};
		room2_Photo {
			-"фотография|страница|фото";
			nam = "room2_album_8";
			pageDsc = function()
				if _'room2_s'.pl_high == 0 then
					if _'room2_album_8':hasnt'seen_on_high' then
						return "    Хм, эта фотография смазанная и нечёткая. Никак нельзя понять, что на ней запечатлено. Зачем она здесь?";
					else
						return "    Фотография опять смазанная и нечёткая. Ты уже не уверена, что тебе не привиделась та ужасная картина."
					end
				else
					local txt = "";
					if _'room2_album_8':hasnt'seen_on_high' then
						mp.score=mp.score+1;
						txt = " Внезапно ты понимаешь: в этом камне заключено чистое Зло! Оно позволило доставить себя из пустыни, а затем расправилось с участниками экспедиции. И, возможно, с тётей тоже. Камень нужно уничтожить!";
					end;
					return "    Фотография сделана в замкнутом помещении с чёрными стенами, полом и потолком. Все восемь участников экспедиции стоят перед объективом. Совершенно голые, с залитыми кровью плечами, они держат собственные головы в вытянутых вперёд руках. Глаза распахнуты в ужасе, рты перекошены в безмолвном крике.^^Камень вспыхивает изнутри красным светом." .. txt
				end
			end
		};
	};
}:attr'openable,~open';

room2_Exhibit {
	-"карта|маршрут";
	nam = "room2_map";
	description = function (s)
		local _study = room2_check_uni(3);
		if _'room2_s'.pl_high == 0 then
			return "Большая карта СССР и прилегающих стран 1946-го года, на которую нанесена красная линия маршрута экспедиции. Пунктирная линия Москва—Саратов—Ташкент—Самарканд обозначает путь по железной дороге. Двойная линия Самарканд—Коканд—Ош—перевал Талдык—Кашгар проходит по маршрутам средневекового Шёлкового Пути.".._study.." От Кашгара и в самый центр безлюдной пустыни Такла-Макан — линия тонкая и прямая, словно подробных данных о том, как именно продвигалась экспедиция, не было. Там, где кончается эта линия, нарисован красный кружок с загадочной меткой «{$fmt b|КФ937}».";
		else
			return "Большая карта СССР и прилегающих стран 1946-го года, на которую нанесена красная линия маршрута экспедиции: сначала по железной дороге, затем через горные долины по маршрутам средневекового Шёлкового Пути.".._study.." И, наконец, в самое сердце смертельной пустыни Такла-Макан, где пульсирует чёрный треугольник.";
		end
	end;
}

----[[
--  #####
-- ##   ##
-- ##   ## ##   ## ######  ##   ## ## # ##  #####  ##   ## ##   ##  #####
-- ##   ## ##  ##  ##   ## ##   ##  # # #  ##   ## ##   ## ##  ### ##   ##
-- ##   ## #####   ######  ##   ##   ###   ######  ####### ## # ## ######
-- ##   ## ##  ##  ##       ######  # # #  ##      ##   ## ###  ## ##
--  #####  ##   ## ##           ## ## # ##  #####  ##   ## ##   ##  #####
--                          #####
--]]

room2_Far {
	-"лес,осинник|деревья|сосны,осины,тени|чаща";
	nam = "room2_forest";
	description = function (s)
		if _'room2_s'.pl_high == 0 then
			return "Старый смешанный лес: величавые сосны тянутся к уже совсем летнему небу, а под ними — непролазный, тёмный осинник."
		else
			return "Лес вдруг стал темнее и зловещее. Старые сосны скрипят, качаясь на ветру (но ветра ты не чувствуешь), а в непроходимом осиннике передвигаются медленные тени. Огородное пугало, раскинувшее перед лесом свои руки, кажется ещё меньше на фоне подступившей чащи."
		end
	end;
	['before_Walk,Enter'] = function(s) mp:xaction("Walk", _"@n_to") end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}

room2_Far {
	-"огород,заросший,каркас,луг|теплица|трава";
	nam = "room2_garden";
	description = function (s)
		if _'room2_s'.pl_high == 0 then
			return "Неухоженный, не готовый к сезону огород. От луга вокруг его отличают только пустой каркас теплицы да высокое старое пугало."
		else
			return "Стебли сорной травы тянутся вверх к свету, покачиваясь на несуществующем ветру. И как будто сторонятся старого пугала."
		end				
	end;
	['before_Walk,Enter'] = "Тебе там нечего делать, да и к лесу приближаться не хочется.";
	found_in = {'room2_terassa','room2_on_terrasa'};
}

room2_Far {
	-"небо|солнце|облака,волны";
	nam = "room2_sky";
	description = function (s)
		if _'room2_s'.pl_high == 0 then
			return "Чистое, глубоко-синее небо с ярким и уже почти по-летнему жарким солнцем."
		else
			return "Небо кажется ещё глубже и ещё более синим, чем раньше. Ты прямо-таки видишь, как от ослепительно яркого солнца расходятся волны света и жара."
		end
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}

room2_Far {
	-"пугало|руки,палки|глаза|мяч,уилсон,рот";
	nam = "room2_scarecrow";
	friendly = false;
	description = function (s)
		local _txt = s:hasnt'seen' and " (Уилсон?!)" or ""
		local _needhelp = s.friendly and "^Тебе хочется как-то помочь пугалу в его непростой миссии." or ""
		if _'room2_s'.pl_high == 0 then
			return "Большое старое пугало встаёт над высокой травой огорода, раскинув в стороны длинные руки-палки — последний защитник между лесом и домом. На него надет потрёпанный рабочий халат с полустёртым логотипом. Вместо головы — дырявый волейбольный мяч".._txt..", на котором углём нарисованы круглые чёрные глаза и зубастый рот." .. _needhelp
		else
			local _t = s:has'seen_before_high' and " ещё более" or ""
			return "Старое пугало".._t.." походит на последнего защитника некогда большой армии. Он стойко возвышается над змеящимися стеблями сорной травы. Он раскинул руки в стороны, чтобы то ли не пустить лес к людям, то ли удержать людей от похода в чащу. Он оборачивается и гримасничает — угольные глаза меняют размер и сдвигаются по голове-мячу, а зубастый рот то открывается, то закрывается." .. _needhelp
		end				
	end;
	before_WaveHands = function(s)
		if _'room2_s'.pl_high == 1 then
			if not s.friendly then
				s.friendly = true;
				return "Ты вскидываешь руку и что есть силы машешь пугалу. И оно — должно быть, от порыва ветра (какого ветра?) — поворачивается туда-сюда, махнув тебе рукавом халата в ответ."
			else
				return "Ты снова машешь пугалу, а оно отвечает. Почему-то тебе от этого радостно."
			end
		end
		return "Ты помахала руками, но пугало не ответило.";
	end;
	before_Walk = "Пожалуй, нет.";
	["life_Give,Show"] = function(s,w)
		if s.friendly then
			p(w:Noun'им' .. " явно не поможет пугалу в его нелёгком деле защиты дома.");
		else
			return false
		end
	end;
	before_Shoot = function(s, w)
		if not w and pl:have('gun') then
			w = _'gun';
		end
		if(w == _'gun') then
			return "Ты точно не решишь своих проблем, застрелив пугало."
		else
			return false
		end;
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}

room2_Far {
	-"старый халат, халат, логотип|лого";
	nam = "room2_scarecrow_logo";
	description = function (s)
		local _txt = "Полустёртое лого на халате: "
		if _'room2_s'.pl_high == 0 then
			return _txt.."«Ми…кат…ик»."
		else
			return _txt.."«Мискатоник»."
		end				
	end;
	found_in = {'room2_terassa','room2_on_terrasa'};
}
