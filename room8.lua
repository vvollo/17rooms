mp.auto_animate = false

global {
  list_clothing = std.list {};
}

game : dict {
  ["блузка/рд"] = 'блузки';
  ["блузка/вн"] = 'блузку';
  ["блуза/вн"] = 'блузу';
  ["блуза/рд"] = 'блузы';
  ["штаны/вн"] = 'штаны';
  ["штаны/рд"] = 'штанов';
  ["твидовый/рд"] = 'твидового';
  ["твидовый/вн"] = 'твидовый';
}

-- Синонимы из Cloak of Darkness. Не знаю почему это не стандарт.
Verb {
  '#PutOn8',
  'повес/ить',
  '~ {noun}/вн,held на {noun}/вн,2,scene: PutOn',
  '~ на {noun}/вн,2,scene {noun}/вн,held: PutOn reverse',
  '~ {noun}/вн,held в {noun}/вн,2,scene: Insert',
}
Verb {
  '#PutOn8_2',
  'остав/ить',
  '~ {noun}/вн,held на {noun}/пр,2,scene: PutOn',
}

-- Доступное пространство имён для объектов - все имена объектов должны начинаться с "room8_" или "garderob_" 
-- Все описания можно менять
-- Задача: Игрок должен получить доступ на запад с помощью предмета thooskey. Изначально он должен быть закрыт. Игрок может придти в комнату как с этим предметом, так и без него

function room8_switch_temperature(temp, forced, showmsg)
  local oldtemp = _('room8_garderob')._mode
  -- TODO: очень тяжёлый цикл, надо как-то оптимизировать
  list_clothing:for_each(function(v)
    if (forced and v:where() ~= nil and v:where().nam == 'room8_control') then
      return
    end
    if (
      v.mode ~= nil
      and v:where() ~= nil
      and v:where().nam ~= 'emptyroom'
    ) then
      local newobject = nil
      if temp == 'hot' and v.paired_hot ~= nil then
        newobject = _(v.paired_hot)
      end
      if temp == 'cold' and v.paired_cold ~= nil then
        newobject = _(v.paired_cold)
      end
      if temp == 'neutral' and v.paired_neutral ~= nil then
        newobject = _(v.paired_neutral)
      end
      if newobject ~= nil then
        -- dprint('Меняем местами '..v.nam ..' и '..newobject.nam)
        move(newobject, v:where());
        if (v:has('worn')) then
          newobject:attr('worn')
        else
          newobject:attr('~worn')
        end
        -- ЭТА СТРОКА ТРЕБУЕТ КОМНАТУ emptyroom В ФИНАЛЬНОЙ ИГРЕ
        move(v, _('emptyroom'));
      end
    end
  end)
  _('room8_garderob')._mode = temp
  if not showmsg then
    return
  end
  if temp == 'cold' then
    return 'В комнате становится холодно. Мороз захватывает вещи и выворачивает их. Твоя одежда покрывается мехом. Гардероб готов к зиме.'
  end
  if temp == 'hot' then
    return 'В комнате становится жарко. Жара берёт каждую вещь и выжимает её для того, чтобы подготовить гардероб к летнему дню.'
  end
  if temp == 'neutral' then
    return 'Комната возвращается в свою скучную неопределённо тёплую атмосферу.'
  end
end

local function room8_drop_items()
	local need_lever = (here()._mode ~= 'neutral');
	if need_lever then
		room8_switch_temperature('neutral', false, false);
	end;
  local need_take_clothing = false;
  local need_wear_clothing = false;
	local need_cloth = false;

  list_clothing:for_each(function(v)
    -- собрать и надеть свои вещи
    if (v:access() and v.own_clothes) then
        if not have(v) then
            need_take_clothing = true
            take(v)
        end
        if v:has('~worn') then
            need_wear_clothing = true
            v:attr('worn');
        end
    end

    -- снять чужие вещи
    if (not v.own_clothes and v:has('worn')) then
			v:attr('~worn');
    end

	  -- повесить остальные в шкаф
    if (v:where() ~= nil and not v.own_clothes and v:where().nam ~= 'room8_clothes' and v.mode == 'neutral') then
			move(v, 'room8_clothes');
			need_cloth = true;
    end
  end)
	if need_lever or need_cloth or need_wear_clothing or need_take_clothing then
		p 'Ты ';
    local txt = ''
    if need_take_clothing then
      txt = 'собираешь свои вещи'
      if need_wear_clothing then
        if need_cloth or need_lever then
          txt = txt .. ', '
        else
          txt = txt .. ' и '
        end
        txt = txt .. 'надеваешь их'
      end
    elseif need_wear_clothing then
      txt = 'надеваешь свои вещи'
    end
		if need_cloth then
      if (txt ~= '') then
        if (need_lever) then
          txt = txt .. ', '
        else
          txt = txt .. ' и '
        end
      end
			txt = txt .. 'аккуратно вешаешь одежду обратно в шкаф'
		end;
    if need_lever then
      if (txt ~= '') then
        txt = txt .. ' и '
      end
      txt = txt .. 'возвращаешь рычаг в среднее положение.'
    else
      txt = txt .. '.'
    end;
    pn(txt)
	end;
end;

room {
	nam = "room8_garderob";
	title = "Гардеробная комната";
	dsc = function(s)
    local description = '';
    if s.hot() then
      description = [[Жарко. ]];
    end
    local clothes = ''
    if _('room8_lock').obj[1] ~= nil then
      clothes = clothes .. 'На замке двери висит '.._('room8_lock').obj[1]:noun('им')..'.';
    end
    if _('room8_control').obj[2] ~= nil then
      clothes = clothes .. 'На рычаге висит '.._('room8_control').obj[2]:noun('им')..'.';
    end
    return description..[[
      Ты стоишь в маленьком повороте прихожей, между шкафом с одеждой и пустой стеной, украшенной ярким плакатом. Рядом с плакатом находится серый рычаг с фигурной рукояткой. Комната продолжает прихожую (на западе) и упирается в дверь гаража (на востоке). Возле стены стоит пьедестал с надписью «Машина времени».
    ]]..clothes;
  end;
	e_to = function()
    if _('room8_garagedoor'):has('locked') then
      p 'Дверь закрыта на электронный замок.';
      return;
    end;
    room8_drop_items();
    return 'room9_garazh';
  end;
	w_to = function()
    room8_drop_items();
    return 'room3_hall';
  end;
  _mode = 'neutral';
  hot = function()
    return here()._mode == 'hot'
  end;
  cold = function()
    return here()._mode == 'cold'
  end;
  temperature = function(temp)
    if (temp ~= 'hot' and temp ~= 'cold' and temp ~= 'neutral') then
      return
    end
    return room8_switch_temperature(temp, false, true)
  end;
	before_Listen = function(s)
    if s.cold() then
      return "Здесь тихо, и ты слышишь только своё замерзающее дыхание.";
    elseif s.hot() then
      return "Быстро разогретые крючки шкафа тихо шипят. Молчание.";
    else
      return "Тишина.";
    end
  end;
}

obj {
  -"вешалка/жр,но|вешалки/мн,жр,но";
	nam = "room8_hanger";
  found_in = 'room8_clothes';
  description = 'Здесь нет вешалок, одежда висит на крючках.';
}: attr 'concealed,static';

obj {
  -"рукоятка,рукоятка рычага/жр,но|монстр/мн,од|язык/но,мр";
  nam = 'room8_control_end';
  found_in = 'room8_control';
  description = 'Изогнутый декоративный крюк на конце рычага изображает язык милого монстра. За эту рукоятку удобно хвататься.';
  before_Receive = function(self, thing)
    mp:xaction('PutOn', thing, _('room8_control'));
  end;
}: attr 'concealed,static,~animate';

obj {
  -"единорог/мр,од|единороги/мр,од,мн|фигура/жр,но|фигуры/мн,жр,но";
  nam = 'room8_clothes_details';
  found_in = 'room8_garderob';
  description = 'Сцены из жизни какой-то девушки с мечом, которая захватывает волшебную страну единорогов, находит там какого-то пучеглазого монстра и уезжает с ним в большой дом, который подозрительно напоминает дом твоей тёти. Хм.';
}: attr 'concealed,static';

obj {
	-"рычаг,кондиционер/мр,но";
	nam = "room8_control";
  found_in = 'room8_garderob';
	description = function(self)
    local r = 'Это тяжёлый вертикальный рычаг с рукояткой в виде изогнутого крюка'
    if here().cold() then
      r = r .. ', который поднят в сторону надписи "ШЕРСТЬ". Его можно '..fmt.b('толкнуть')..' вниз, в нейтральное положение.'
    elseif here().hot() then
      r = r .. ', который опущен в сторону надписи "ПЕСОК". Его можно '..fmt.b('потянуть')..' вверх, в нейтральное положение.'
    else
      r = r .. ', который выставлен между надписей "ШЕРСТЬ" и "ПЕСОК". Его можно '..fmt.b('потянуть')..' вверх или '..fmt.b('толкнуть')..' вниз.'
    end
    pn(r)
    if self.obj[2] ~= nil then
      pn ('На рычаге висит '..self.obj[2]:noun('им')..'.')
    end;
    return true
  end;
  after_Receive = function(self, thing)
    local weight = 0
    if thing.weight ~= nil then
      weight = thing.weight
    end
    if weight == 0 then
      return ('Рычаг, конечно, не рассчитан на одежду, но '..thing:noun('им')..' для него — не проблема.');
    end
    if weight == 1 then
      return ('Рычаг издаёт короткий скрип, но в остальном не замечает, что на нём висит '..thing:noun('им')..'.');
    end
    if weight == 2 then
      return ('Рычаг скрипит, но выдерживает вес '..thing:noun('рд')..'.');
    end
    if weight > 2 then
      if here().hot() then
        return 'Рычаг громко скрипит под тяжестью одежды.';
      else
        return 'Рычаг со скрипом падает под тяжестью одежды в нижнее положение. '..room8_switch_temperature('hot', true, true)
      end
    end
  end;
  before_Pull = function(self)
    if here().hot() and self.obj[2] ~= nil and self.obj[2].weight ~= nil and self.obj[2].weight > 2 then
      return 'Тяжёлая одежда на рычаге не даёт поднять его.'
    end;
    if here().cold() then
      return 'Это крайнее положение.'
    end
    if here().hot() then
      return here().temperature('neutral')
    end
    return here().temperature('cold')
  end;
  before_Push = function()
    if here().hot() then
      return 'Это крайнее положение.'
    end
    if here().cold() then
      return here().temperature('neutral')
    end;
    return here().temperature('hot')
  end;
  capacity = 2;
}: attr 'static,supporter,scenery';

obj {
  -"зубчатый ключ,ключ";
  nam = "thooskey";
  description = "Зубчатый ключ.";
  found = false;
};

obj {
  -"дверь/жр,но";
  nam = 'room8_garagedoor';
  found_in = 'room8_garderob';
  with_key = 'thooskey';
  after_Unlock = function(s)
    remove('thooskey');
    mp.score=mp.score+1;
    return 'Ключ застревает в замке, но дверь всё-таки открывается.';
  end;
  description = function(s)
    if s:has('locked') then
      return "Закрытая дверь, на которой мигает электронный замок.";
    end
    return "Дверь в гараж, распахнутая настежь. Можно идти на запад.";
  end;
  when_open = 'Дверь в гараж открыта.';
}: attr 'scenery,openable,lockable,locked';

obj {
  -"замок,электронный замок/мр,но";
  nam = 'room8_lock';
  before_Burn = function(self, thing)
    if not (thing ^ 'matches' or thing ^ 'kitchen_lighter' or thing ^ 'kerosin' or thing ^ 'lamp') then
      return 'Во-первых, '..thing:noun('им')..' ты не подожжёшь. Во-вторых, пожар скорее сожжёт весь дом, чем замок на этой двери.';
    end
    return 'Стальной корпус от этого не разогреется, а костёр скорее сожжёт дом, чем отдельный электронный замок. Плохая идея.';
  end;
  before_Unlock = function(self, thing)
    pn('Жаль, но электронный замок не открывается '..thing:noun('тв')..', хотя в двери ты замечаешь замочную скважину.');
    mp:xaction('Unlock', _('room8_garagedoor'), thing);
  end;
  found_in = 'room8_garderob';
  before_Attack = 'Антивандальная защита замка состоит в том, что у него нет отверстий, а стальной корпус нельзя пробить.';
  before_Touch = function(s)
    if here().hot() then
      return "Замок обжигающе горяч на ощупь.";
    elseif here().cold() then
      return "Осторожно, так и примёрзнуть пальцем можно. Он же ледяной.";
    end;
    return "Металл как металл.";
  end;
  capacity = 1;
  after_Receive = function(self, thing)
    local is_boiling = here().hot() and thing.mode == 'cold';
    if is_boiling and not self:has('broken') and _'room8_garagedoor':has('locked') then
      pn ('Из-под '..thing:noun('рд')..' доносится резкий писк, затем что-то начинает шипеть и ты видишь струйку дыма. Дверь распахивается настежь.');
      _('room8_garagedoor'):attr('open');
      _('room8_garagedoor'):attr('~locked');
      mp.score=mp.score+1;
      self:attr('broken')
      remove('thooskey');
      _'thooskey'.found = true;
      return true;
    end;
    return false;
  end;
  description = function(s)
    local description = 'Электронный замок со стальным корпусом и гордой наклейкой «Модель "Невзломайка" с антивандальной защитой. Проверено в режиме от минус сорока до сорока градусов.» Это маленькая коробка с двумя лампочками.';
    if s:has('broken') then
      description = description .. ' Внутри замка что-то перегрелось и расплавилось. Он безнадёжно сломан.'
    else
      description = description .. ' Сейчас горит красная лампочка с надписью "Требуется ключ-карта".';
      if here().hot() then
        description = description .. " Воздух вокруг замка заметно нагрет, а лампочка немного мигает.";
      elseif here().cold() then
        description = description .. " Наклейка покрылась коркой льда.";
      end;
    end
    pn(description);
    return false;
  end;
}: attr 'scenery,supporter,transparent';

clothing = Class {
	find_same = function(s)
		local c = nil; -- одежда того же уровня
		local oldlevel = s.level or 0;
		local oldpart = s.part or 'top';
		me():inventory():for_each(function(v)
			if not v:has('clothing') or not v:has('worn') then
				return
			end
			local newlevel = v.level or 0;
			local newpart = v.part or 'top';
			if (v ~= s and newlevel == oldlevel and newpart == oldpart) then
				c = v
			end
		end)
		return c;
	end;
	["before_Take,Wear"] = function(s)
		if _"room14_dress".worn then
			return 'Нет, пока на тебе платье.';
		else
			return false;
		end;
	end;
	refuse = function(s)
		--"устраивать"
		--"собственный"
		return "Тебя вполне {#word/устраивать,#first,нст} {#word/собственный,#first} {#first}, спасибо!";
	end;
	before_Wear = function(s)
		local c = s:find_same();
		if c then
			return mp:xaction('refuse', c);
		end;
		local _level = s.level or 0;
		if (_level == 4) then
			--"великоват"
			return '{#First} {#word/великоват,#first} для тебя. Да и для тётушки, если подумать, тоже. Интересно, зачем {#firstit} здесь.';
		end;
		return false;
	end;
	before_Disrobe = function(s)
		if s.own_clothes and s:has'worn' then
			return 'Да ни за что!';
		else
			return false;
		end;
	end;
	after_Wear = function(s)
		local _part = s.part or 'top';
		if _part == 'feet' and not _'thooskey'.found then
			p('Ты пытаешься надеть ' .. s:noun('вн') .. ', но тебе что-то мешает. Пошарив рукой внутри, ты находишь ' .. _'thooskey':noun'вн' .. '.');
			take('thooskey');
			_'thooskey'.found = true;
		else
			return false;
		end
	end;
}: attr 'clothing';

-- Да, ты можешь писать "открыть крючок" потому что это синоним шкафа.
-- Но то, что крючки не смоделированы, должно намекать на их несущественность.
obj {
  -"шкаф,гардероб/мр,но|крючки/мр,мн,но|крючок/мр,но|одежда/жр,но";
  nam = 'room8_clothes';
  before_Receive = function(self, thing)
    if not thing:has('clothing') then
      return 'Это — шкаф только для одежды.';
    end;
    return false;
  end;
  after_Receive = function(self, thing)
    return('Ты находишь свободный крючок и вешаешь '..thing:noun('вн')..' в шкаф.');
  end;
  found_in = 'room8_garderob';
  description = function(self)
    local dsc = 'Старинный платяной шкаф с резными фигурами на дверцах.';
    if self:has 'open' and #self.obj > 3 then
      dsc = dsc .. ' Плотно забит одеждой.';
    end
    pn(dsc);
    return false;
  end;
}: attr 'container,openable,static,scenery';

--[[
level = 0: шарф, головной убор, носки
level = 1: штаны, юбка
level = 2: блузка, футболка
level = 3: пиджак, куртка
level = 4: шуба
--]]

clothing {
  -"фетровая шляпа,шляпа/жр,но";
  nam = 'room8_cap';
  level = 0;
  part = 'head';
  mode = 'neutral';
  found_in = 'room8_clothes';
  paired_hot = 'room8_baseballcap';
  paired_cold = 'room8_ushanka';
  description = 'Старая фетровая шляпа, какую носят герои нуарных детективов.';
  weight = 0;
}

clothing {
  -"чёрная ушанка,ушанка/жр,но";
  nam = 'room8_ushanka';
  part = 'head';
  level = 0;
  weight = 0;
  mode = 'cold';
  paired_hot = 'room8_baseballcap';
  paired_neutral = 'room8_cap';
  description = 'Чёрная тёплая ушанка с жёлтым геральдическим львом на лбу.';
}

-- я не знаю почему но auto_animate считает ЭТО живым
clothing {
  -"белая бейсболка,бейсболка/жр,но";
  nam = 'room8_baseballcap';
  part = 'head';
  level = 0;
  mode = 'hot';
  paired_neutral = 'room8_cap';
  paired_cold = 'room8_ushanka';
  description = 'Новенькая белая бейсболка.';
  weight = 0;
}: dict {
  ['бейсболка/вн'] = 'бейсболку';
  ['белая бейсболка/вн'] = 'белую бейсболку';
  ['бейсболка/дт'] = 'бейсболке';
  ['белая бейсболка/дт'] = 'белой бейсболке';
}: attr '~animate';

-- Сюжетная проблема: так как мы моделируем одежду до уровней,
-- героиня должна быть во что-то одета изначально.
-- Придётся давать ей вещи в самом начале игры.
clothing {
  -"деловые штаны,штаны/ср,мч,мн";
  nam = 'room8_pants';
  own_clothes = true;
  part = 'bottom';
  mode = 'neutral';
  description = 'Чёрные деловые штаны.';
  paired_hot = 'room8_shorts';
  paired_cold = 'room8_winterpants';
  level = 1;
  weight = 2;
}: attr 'worn,concealed';

clothing {
  -"шорты/ср,мч,мн";
  nam = 'room8_shorts';
  own_clothes = true;
  part = 'bottom';
  mode = 'hot';
  paired_neutral = 'room8_pants';
  paired_cold = 'room8_winterpants';
  description = 'Короткие серые шорты.';
  level = 1;
  weight = 1;
}: attr 'concealed';

clothing {
  -"зимние штаны,штаны/ср,мч,мн";
  nam = 'room8_winterpants';
  own_clothes = true;
  part = 'bottom';
  mode = 'cold';
  paired_neutral = 'room8_pants';
  paired_hot = 'room8_shorts';
  weight = 3;
  description = 'Зимние утеплённые штаны. Очень тяжёлые.';
  level = 1;
}: attr 'concealed';

clothing {
  -"белая блузка,блузка,белая блуза,блуза/жр";
  nam = 'room8_blouse';
  part = 'top';
  description = 'Белая блузка с принтом картины Малевича на груди.';
  mode = 'neutral';
  own_clothes = true;
  level = 2;
  weight = 1;
  paired_cold = 'room8_winterblouse';
  paired_hot = 'room8_shortblouse';
}: attr 'worn,concealed';

clothing {
  -"вязаная блуза,шерстяная блуза,блуза/жр";
  nam = 'room8_winterblouse';
  own_clothes = true;
  part = 'top';
  description = 'Белая вязаная блузка.';
  mode = 'cold';
  paired_neutral = 'room8_blouse';
  paired_hot = 'room8_shortblouse';
  level = 2;
  weight = 2;
}: attr 'concealed';

clothing {
  -"блузка,мини-блузка,мини-блуза,блуза/жр";
  nam = 'room8_shortblouse';
  own_clothes = true;
  part = 'top';
  description = 'Белая мини-блузка. Может быть, даже мини-мини.';
  mode = 'hot';
  paired_neutral = 'room8_blouse';
  paired_cold = 'room8_winterblouse';
  level = 2;
  weight = 1;
}: attr 'concealed';

clothing {
  -"жилет/мр";
  nam = 'room8_formalvest';
  own_clothes = true;
  description = 'Чёрный короткий жилет.';
  level = 3;
  weight = 1;
  part = 'top';
  mode = 'hot';
  paired_neutral = 'room8_formalcoat';
  paired_cold = 'room8_winter_formalсoat';
}: attr 'concealed';

clothing {
  -"твидовый пиджак,пиджак/мр,но";
  nam = 'room8_winter_formalсoat';
  own_clothes = true;
  description = 'Чёрный твидовый пиджак. Очень тёплый.';
  level = 3;
  weight = 1;
  part = 'top';
  mode = 'cold';
  paired_neutral = 'room8_formalcoat';
  paired_hot = 'room8_formalvest';
}: attr 'concealed';

clothing {
  -"чёрный пиджак,черный пиджак,пиджак/мр,но";
  nam = 'room8_formalcoat';
  paired_hot = 'room8_formalvest';
  paired_cold = 'room8_winter_formalсoat';
  description = 'Чёрный женский пиджак. Выглядит очень профессионально.';
  own_clothes = true;
  level = 3;
  weight = 2;
  part = 'top';
  mode = 'neutral';
}: attr 'worn,concealed';

take('room8_pants');
take('room8_blouse');
take('room8_formalcoat');

clothing {
  -"гольф/мр";
  nam = 'room8_golf';
  level = 2;
  weight = 2;
  part = 'top';
  mode = 'cold';
  paired_neutral = 'room8_sportshirt';
  paired_hot = 'room8_tshirt';
  description = 'Колючий шерстяной гольф, в котором всегда тепло.';
}

clothing {
  -"майка/жр";
  nam = 'room8_tshirt';
  part = 'top';
  mode = 'hot';
  level = 2;
  paired_cold = 'room8_golf';
  paired_neutral = 'room8_sportshirt';
  description = 'Лёгкая белая майка-безрукавка, на спине нарисованы крестики-нолики.';
  weight = 1;
}

clothing {
  -"футболка/жр";
  nam = 'room8_sportshirt';
  mode = 'neutral';
  part = 'top';
  level = 2;
  found_in = 'room8_clothes';
  paired_cold = 'room8_golf';
  paired_hot = 'room8_tshirt';
  description = 'Спортивная полосатая футболка с короткими рукавами. На спине нарисован номер 7.';
  weight = 1;
}

clothing {
  -"шуба/жр|мутон/мр";
  nam = 'room8_wintercoat';
  part = 'top';
  level = 4;
  weight = 3;
  mode = 'cold';
  paired_hot = 'room8_overcoat';
  paired_neutral = 'room8_raincoat';
  description = 'Меховая мутоновая шуба. Безразмерная. Не совсем подходящая одежда для отапливаемых помещений. У меха какой-то странный зелёный оттенок.';
}

clothing {
  -"дождевик/мр";
  nam = 'room8_raincoat';
  part = 'top';
  paired_cold = 'room8_wintercoat';
  paired_hot = 'room8_overcoat';
  found_in = 'room8_clothes';
  level = 4;
  weight = 3;
  mode = 'neutral';
  description = 'Яркий синий непромокаемый дождевик. Безразмерный.';
}

clothing {
  -"накидка/жр";
  nam = 'room8_overcoat';
  part = 'top';
  paired_cold = 'room8_wintercoat';
  paired_neutral = 'room8_raincoat';
  level = 4;
  weight = 1;
  mode = 'hot';
  description = 'Лёгкая цветная полупрозрачная накидка. Безразмерная.';
}

clothing {
  -"шарф/мр";
  nam = 'room8_winterscarf';
  part = 'neck';
  level = 0;
  mode = 'cold';
  paired_neutral = 'room8_shawl';
  paired_hot = 'room8_kerchief';
  description = 'Шерстяной клетчатый шарф с надписью «ЭНИГМА».';
  weight = 1;
}

clothing {
  -"шаль/жр";
  nam = 'room8_shawl';
  found_in = 'room8_clothes';
  part = 'neck';
  level = 0;
  weight = 1;
  mode = 'neutral';
  paired_cold = 'room8_winterscarf';
  paired_hot = 'room8_kerchief';
  description = 'Клетчатая шаль с витыми узорами по краям.';
}

clothing {
  -"платок/мр";
  nam = 'room8_kerchief';
  part = 'neck';
  level = 0;
  mode = 'hot';
  paired_cold = 'room8_winterscarf';
  paired_neutral = 'room8_shawl';
  description = 'Лёгкий прозрачный платок для головы.';
  weight = 0;
}

obj {
  -"машина времени,машина/жр,но|пьедестал,переключатель/мр,но|кнопка/жр,но";
  nam = 'room8_timemachine';
  found_in = 'room8_garderob';
  description = 'Маленький пьедестал с надписью «Машина времени двунаправленная». На пьедестале находится переключатель, который указывает на положение «ВЫКЛ».';
  after_SwitchOn = function(s)
	s:attr('~on');
	walk 'room8_tmach_start';
  end;
}: attr 'switchable,static,scenery';

cutscene {
	nam = 'room8_tmach_start';
	text = {
		"Экспериментальная разработка, способная на несколько секунд доставить вас в собственное недалёкое прошлое или будущее.";
		"Работает в режиме «только чтение», то есть вы можете лишь наблюдать события, но не вмешиваться.";
		"Также не забывайте, что показанное будущее -- лишь один из возможных вариантов развития событий, хотя и наиболее вероятный.";
	};
	next_to = 'room8_tmach_choice'
}

dlg {
	nam = 'room8_tmach_choice';
	phr = {
		[[Куда вы хотите отправиться?]];
		{
			'В прошлое.',
			function() walk 'room8_tmach_past'; end;
		},
		{
			'В будущее.',
			function() walk 'room8_tmach_future'; end;
		},
		{
			'Я передумала!',
			function() walk 'room8_garderob'; end;
		},
	};
}

cutscene {
	nam = 'room8_tmach_past';
	text = {
		"Ты снова возле дома.";
		"Заходишь за него и направляешься к закрытым шкафам на террасе. Скоро ты их откроешь.";
		"Твой мимолётный взгляд скользит по плющу, опутавшему дом.";
		"Ты замечаешь, что на земле под плющом ничего нет, никаких ключей.";
		"Стоп! Как такое может быть?";
		"...";
		"Реальность немного расплывается… а затем собирается воедино.";
	};
	next_to = 'room8_garderob'
}

cutscene {
	nam = 'room8_tmach_future';
	text = {
		"Ты на улице Петербурга.";
		"На земле валяются несколько окровавленных тел, вокруг ни души.";
		"Внезапно из-за угла показывается чудовище с острыми когтями. Оно замечает тебя!";
		"Ты хочешь бежать, но от страха не можешь пошевелиться.";
		"Чудовище несётся к тебе, чтобы растерзать!";
		"В последний момент ты вдруг понимаешь, что монстр ОЧЕНЬ похож на твою тётушку!!!";
		"...";
		"Реальность немного расплывается… а затем собирается воедино.";
	};
	next_to = 'room8_garderob'
}

obj {
  -"плакат,постер,комикс/мр,но";
  nam = 'room8_poster';
  found_in = 'room8_garderob';
  description = [[
    Цветной комикс: человек заходит в магазин одежды.^
    — Я ищу что-нибудь, что кричало бы «Тяжёлый металл!»^
    — Мы положили в каждый карман вот этого пуховика по гантели. Надевать для примерки будете?
  ]];
}: attr 'static,scenery';

obj {
  -"прихожая/жр,но|поворот/ср,но";
  nam = 'room8_out_e';
  found_in = 'room8_garderob';
  description = 'Отсюда видна часть прихожей.';
}: attr 'static,concealed';

obj {
  -"карман/мр,но|карманы/мн,мр,но";
  nam = 'room8_out_pockets';
  before_Drop = 'Нет, ты же можешь таскать с собой столько вещей!';
  before_Receive = function(self, thing)
    mp:xaction('Take', thing)
  end;
  before_Exam = function(s)
    mp:xaction('Inv')
  end;
--  description = 'Карманы пусты, в них нет ничего интересного.';
}: attr 'concealed,container';
take('room8_out_pockets');

obj {
  -"стены/мн,жр,но|обои/мн,ср,но|стена/жр,но";
  nam = 'room8_out_wallsw';
  found_in = 'room8_garderob';
  description = 'Обычные стены с бежевыми обоями. На одной из стен висит постер.';
}: attr 'scenery,~animate';

obj {
  -"пол,линолеум/мр,но";
  nam = 'room8_out_floor';
  found_in = 'room8_garderob';
  description = 'Непримечательный тёмно-коричневый линолеум.';
}: attr 'scenery,~animate';

obj {
  -"потолок/мр,но";
  nam = 'room8_out_ceiling';
  found_in = 'room8_garderob';
  description = 'Белый натяжной потолок со встроенными светильниками.';
}: attr 'scenery,~animate';

obj {
  -"светильник/мр,но|светильники/мр,мн,но|лампочка/жр,но|лампочки/мн,жр,но";
  nam = 'room8_out_ceilinglight';
  found_in = 'room8_garderob';
  description = 'Обычные лампочки в потолке освещают комнату мягким белым светом.';
}: attr 'scenery,~animate,light';

clothing {
  -"юбка/жр";
  nam = 'room8_skirt';
  part = 'bottom';
  weight = 1;
  level = 1;
  found_in = 'room8_clothes';
  mode = 'neutral';
  description = 'Красная длинная юбка в зелёный горошек.';
  paired_hot = 'room8_miniskirt';
  paired_cold = 'room8_coldskirt';
}

clothing {
  -"миниюбка,мини-юбка,юбка,мини/жр";
  nam = 'room8_miniskirt';
  part = 'bottom';
  weight = 1;
  paired_neutral = 'room8_skirt';
  paired_cold = 'room8_coldskirt';
  level = 1;
  mode = 'hot';
  description = 'Красная мини-юбка с зелёными полосами по бокам.'
}: dict {
  ['миниюбка/рд'] = 'миниюбки';
  ['миниюбка/вн'] = 'миниюбку';
  ['мини-юбка/рд'] = 'мини-юбки';
  ['мини-юбка/вн'] = 'мини-юбку';
  ['мини/вн'] = 'мини';
  ['мини/рд'] = 'мини';
}

clothing {
  -"вязаная юбка,юбка/жр";
  nam = 'room8_coldskirt';
  part = 'bottom';
  weight = 2;
  paired_neutral = 'room8_skirt';
  paired_hot = 'room8_miniskirt';
  level = 1;
  mode = 'cold';
  description = 'Длинная вязаная бордовая юбка с фигурной вышивкой по краям.';
}

clothing {
  -"носки/мн";
  nam = 'room8_socks';
  part = 'feet';
  description = 'Чёрные хлопчатобумажные носки.';
  mode = 'neutral';
  found_in = 'room8_clothes';
  paired_hot = 'room8_stockings';
  paired_cold = 'room8_coldsocks';
  level = 0;
  weight = 0;
}

clothing {
  -"чулки/мн";
  nam = 'room8_stockings';
  part = 'feet';
  description = 'Длинные полупрозрачные чёрные чулки из нейлона.';
  mode = 'hot';
  paired_neutral = 'room8_socks';
  paired_cold = 'room8_coldsocks';
  level = 0;
  weight = 0;
}

clothing {
  -"шерстяные носки,носки/мн";
  nam = 'room8_coldsocks';
  part = 'feet';
  description = 'Тёплые шерстяные носки чёрного цвета.';
  mode = 'cold';
  paired_neutral = 'room8_socks';
  paired_hot = 'room8_stockings';
  level = 0;
  weight = 1;
}

clothing {
  -"куртка/жр";
  nam = 'room8_jacket';
  found_in = 'room8_clothes';
  part = 'top';
  level = 3;
  mode = 'neutral';
  paired_cold = 'room8_hoody';
  paired_hot = 'room8_top';
  description = 'Кожаная куртка с нашивкой «ПИНГВИН». Хороша в пасмурный день.';
  weight = 2;
}

clothing {
  -"топ,верх/мр";
  nam = 'room8_top';
  part = 'top';
  level = 3;
  mode = 'hot';
  paired_neutral = 'room8_jacket';
  paired_cold = 'room8_hoody';
  description = 'Белый спортивный верх (топ) из быстро сохнущей ткани.';
  weight = 1;
}

clothing {
  -"толстовка/жр";
  nam = 'room8_hoody';
  part = 'top';
  level = 3;
  paired_neutral = 'room8_jacket';
  paired_hot = 'room8_top';
  mode = 'cold';
  description = 'Серая спортивная толстовка с длинными рукавами.';
  weight = 2;
}

std.for_each_obj(function(v)
  if (v.find_same ~= nil) then
    list_clothing:add(v)
  end
end)
