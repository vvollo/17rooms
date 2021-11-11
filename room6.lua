mp.clear_on_move = false;

room {
    -"кухня,комната";
    nam = "room6_kitchen";
    title = "Кухня";
    dsc = function(s)
        p"Оранжевые стены кухни радуют глаз. Свет пробивается в приоткрытое окно в западной стене.^^Если пойти на север, можно вернуться в столовую, через белую дверь, а облупившаяся деревянная дверь на востоке ведёт в кладовку.";
        if not _'kitchen_old_man'.told_you_a_story then
            DaemonStart('kitchen_old_man');
        end;
	mp.compare_len=5;	-- чтобы "хлеб" не воспринимался как "хлебница"
    end;
    n_to = 'kitchen_door_north';
    e_to = 'kitchen_door_west';
    s_to = function(s)
        p"Вдоль южной стены простирается столешница, но никакого выхода там нет.";
    end;
    w_to = function(s)
        p"В западной стене есть окно, но назвать его выходом сложно.";
    end;
    cant_go = "Отсюда можно пойти только на восток в кладовку и на север в столовую.";
    before_Think = "Хмм.";
    before_Listen = function(s)
        if (_'kitchen_old_man'.counter > 2 and _'kitchen_old_man'.counter < 7) or (_'kitchen_old_man'.counter_lift_interaction == 1 or _'kitchen_old_man'.counter_lift_interaction == 2) or _'kitchen_old_man'.counter_since_fed == 3 or (_'kitchen_old_man'.counter_lift_interaction_2 > 0 and _'kitchen_old_man'.counter_lift_interaction_2 < 6) then
            p"Ты слушаешь, что говорит старик.";
            return true;
        end;
        p"Ничего не слышно."
    end;
    before_Smell = function(s, w)
        if w == nil then
            p"Ничем не пахнет.";
            return true;
        end;
        return false;
    end;
    before_Drop = function(s, i)
	if i:has'edible' then
            p"Не бросай еду на пол.";
            return true;
        end;
        return false;
    end;
    before_Yes = "Ты хочешь ответить, но старик не услышит тебя.";
    before_No = "Ты хочешь ответить, но старик не услышит тебя.";
    obj = {'kitchen_main_table', 'kitchen_grass', 'kitchen_round_table', 'kitchen_lift', 'kitchen_door_north', 'kitchen_door_west', 'kitchen_button_up', 'kitchen_button_down', 'kitchen_old_man', 'kitchen_window', 'kitchen_forest', 'kitchen_walls', 'kitchen_ceiling', 'kitchen_pec', 'kitchen_cat'};
}

function kitchen_drop_items()
    if inside('kitchen_avocado', pl) then
        p"Ты кладёшь авокадо обратно в корзину.";
        move('kitchen_avocado', 'kitchen_basket');
    end;
    if inside('kitchen_avocado_pieces', pl) then
        p"Ты кладёшь ломтики авокадо на столешницу.";
        move('kitchen_avocado_pieces', 'kitchen_main_table');
    end;
    if inside('kitchen_bread', pl) then
        p"Ты кладёшь хлеб обратно в хлебницу.";
        move('kitchen_bread', 'kitchen_breadbox');
        _'kitchen_breadbox':attr('~open');
    end;
    if inside('kitchen_bread_piece', pl) then
        p"Ты кладёшь кусок хлеба на столешницу.";
        move('kitchen_bread_piece', 'kitchen_main_table');
    end;
    if inside('kitchen_sandwich', pl) then
        p"Ты кладёшь бутерброд на столешницу.";
        move('kitchen_sandwich', 'kitchen_main_table');
    end;
    if inside('kitchen_candy', pl) then
        p"Ты кладёшь конфету на стол.";
        move('kitchen_candy', 'kitchen_round_table');
    end;
    if inside('kitchen_lighter', pl) then
        p"Ты кладёшь зажигалку на стол.";
        move('kitchen_lighter', 'kitchen_round_table');
    end;
    mp.compare_len=3;		-- вернуть как было
end;

door {
    -"дверь,дверь в кладовку,восточная дверь,облупившаяся дверь/жр,ед";
    nam = "kitchen_door_west";
    door_to = function(s, d)
        kitchen_drop_items()
        return 'room4_kladovka';
    end;
    with_key = 'longkey';
    after_Unlock = function (s)
        remove 'longkey';
        mp.score=mp.score+1;
        p"Ты отпираешь дверь в кладовку длинным ключом. Ключ тебе больше не понадобится, так что ты оставляешь его в скважине.";
    end;
}: attr 'concealed,openable,locked,lockable,static';

door {
    -"дверь в столовую,северная дверь,белая дверь,дверь/жр,ед,~од";
    nam = "kitchen_door_north";
    door_to = function(s, d)
        kitchen_drop_items()
        return 'room7_stolovaya';
    end;
}: attr 'concealed,open,openable,static';

obj {
    -"длинный ключ,ключ|завитушка";
    nam = "longkey";
    description = "Длинный ключ из чугуна, с завитушкой, похожей на восьмёрку.";
}


obj {
    -"столешница,раковина";
    nam = "kitchen_main_table";
    dsc = "Вдоль южной стены простирается кухонная столешница.";
    description = function(s)
        p"Это обычная столешница, тут есть кухонные приборы, по большей части тебе ненужные, а также раковина, в которой моют продукты или утварь.";
        mp:content(s);
    end;
    obj = {'kitchen_knife', 'kitchen_breadbox'};
}:attr 'static,supporter';

obj {
    -"нож";
    nam = "kitchen_knife";
    description = "Острый кухонный нож с деревянной ручкой.";
}

obj {
    -"прямоугольный стол,стол";
    nam = "kitchen_round_table";
    score = false;
    dsc = "Посреди комнаты стоит прямоугольный стол.";
    description = function(s)
        p"Это стол прямоугольной формы из массива дерева. Он имеет характерные потёртости, сколы и многочисленные следы от ножей. На нём стоит корзина для фруктов.";
        mp:content(s)
    end;
    before_Take = "Это старинный стол из массива дерева. Его невозможно сдвинуть с места.";
    before_Smell = "Стол пахнет каштанами, а ещё чем-то неуловимым.";
    before_LookUnder = function(s)
        if _'kitchen_old_man'.told_you_a_story == true then
            p"Под столом ты находишь выжженную надпись: «Комната #6 для проекта “17 комнат”, авторы: Всеволод Зубарев и Антон Артамонов, 2021. Тестеры: Гога и Пётр. Спасибо за внимание!»";
            if not s.score then
                mp.score=mp.score+1;
                s.score = true;
            end;
        else
            p"Там что-то есть, но ты, пожалуй, потом посмотришь — сейчас есть дела поважнее.";
        end;
    end;
    obj = {'kitchen_basket'};
}:attr 'static,supporter';

obj {
    -"корзина для фруктов,корзина";
    nam = "kitchen_basket";
    description = function (s)
        p"Пологая плетёная корзина для хранения фруктов.";
        mp:content(s);
    end;
    before_Take = "Корзина тебе не понадобится.";
    obj = {'kitchen_avocado'};
}:attr 'static,container,~openable,open,concealed';

obj {
    -"авокадо/ср|фрукт/мр,ед,~од|фрукты/мр,мн,~од";
    nam = "kitchen_avocado";
    description = "Сочное тёмно-зелёное авокадо.";
    before_Eat = "Сначала авокадо нужно порезать — со шкурой его не едят.";
    before_Smell = "У авокадо слабый, но приятный сладкий запах.";
    before_Cut = function(s, w)
        if w == nil then
            p"Чем ты хочешь разрезать авокадо?";
            return true;
        end;
	if mp:check_held(s) or mp:check_held(w) then
		return
	end;
        if w ~= nil then
            if w ^ "kitchen_knife" then
                p"Ты снимаешь кожуру с авокадо, выбрасываешь в окно круглую косточку и разрезаешь его на аккуратные ломтики.";
                move('kitchen_avocado_pieces', me());
                remove 'kitchen_avocado';
                return true;
	    elseif w ^ "dagger" then
                p"Здесь есть более подходящий для этого инструмент.";
                return true;
            else
                p"Этим разрезать авокадо не получится.";
                return true;
            end;
        end;
        return false;
    end;
}:attr 'edible';

obj {
    -"ломтики авокадо,ломтики|авокадо";
    nam = "kitchen_avocado_pieces";
    description = "То, что осталось от авокадо: ровные ломтики.";
    before_Eat = "Авокадо было всего одно, и оно, похоже, предназначено не тебе.";
    before_Cut = "Авокадо уже порезано на ломтики.";
}:attr 'edible';

obj {
    -"хлебница";
    nam = "kitchen_breadbox";
    description = function(s)
        p "Продолговатая, голубого оттенка советская хлебница, которую можно открыть плавным движением. ";
        if s:has 'open' then
            p"Она открыта.";
        else
            p"Она закрыта.";
        end;
        mp:content(s);
    end;
    before_Take = "Она слишком громоздка, чтобы носить с собой. Да и зачем она тебе?";
    obj = {'kitchen_bread'};
}:attr 'static,container,openable,~open';

obj {
    -"буханка чёрного хлеба,буханка|чёрный хлеб,хлеб/но";
    nam = "kitchen_bread";
    was_cut = false;
    description = function(s)
        p"Ещё довольно свежая буханка хлеба."
        if s.was_cut then
            p"Ты уже отрезала от неё кусок.";
        end;
    end;
    before_Eat = "Будь это сегодняшний хлеб, ты бы с удовольствием откусила кусок прямо от корки. Но так тебя не тянет.";
    before_Cut = function(s, w)
        if s.was_cut == true then
            if _'kitchen_old_man'.fed == false then
                p"Пожалуй, одного куска хватит.";
            else
                p"Больше хлеб тебе не потребуется. Можешь вернуть его обратно.";
            end;
            return true;
        end;
        if w == nil then
            p"Чем ты хочешь отрезать от хлеба?";
            return true;
        end;
	if mp:check_held(s) or mp:check_held(w) then
		return
	end;
        if w ~= nil then
            if w ^ "kitchen_knife" then
                p"Ты отрезаешь кусок хлеба и кладёшь буханку обратно в хлебницу.";
                s.was_cut = true;
                move('kitchen_bread_piece', me());
                move('kitchen_bread', 'kitchen_breadbox');
                _'kitchen_breadbox':attr('~open');
                return true;
	    elseif w ^ "dagger" then
                p"Здесь есть более подходящий для этого инструмент.";
                return true;
            else
                p"Этим отрезать от хлеба не получится.";
                return true;
            end;
        end;
        return false;
    end;
}:attr 'edible';

obj {
    -"кусок хлеба,кусок,хлеб";
    nam = "kitchen_bread_piece";
    description = "Кусок хлеба.";
    before_Eat = "Это не твой хлеб.";
    before_Receive = function(s, w)
        if w ^ 'kitchen_avocado_pieces' then
            p"Ты кладёшь авокадо на кусок хлеба. Теперь у тебя есть бутерброд с авокадо! Это то, что хотел старик?";
            move('kitchen_sandwich', me());
            remove 'kitchen_bread_piece';
            remove 'kitchen_avocado_pieces';
            if s.once then
              mp.score=mp.score+1;
            end
            return true;
	else
	    p "Так ты бутерброд не приготовишь.";
	    return true;
        end;
    end;
    before_Cut = "Кусок хлеба уже отрезан.";
}:attr 'edible';

obj {
    -"бутерброд с авокадо,бутерброд";
    nam = "kitchen_sandwich";
    description = "Бутерброд с авокадо: на куске хлеба лежат ломтики авокадо.";
    before_Eat = "К сожалению, придётся отдать его старику.";
    before_Cut = "Кусок хлеба уже отрезан.";
}:attr 'edible';

obj {
    -"кухонный лифт,лифт|ниша";
    nam = "kitchen_lift";
    loc = 'down'; -- / 'up'
    used = false,
    looked_at = false;
    dsc = "В восточной стене есть ниша, в которой обустроен кухонный лифт.";
    description = function(s)
        if s.looked_at == false then
            s.looked_at = true;
            p "Ты видишь лифт для транспортировки еды из кухни, скорее всего на верхний этаж. Вспоминаешь, что видела подобное устройство много раз в фильмах. «Всегда мечтала, чтобы каждое утро мне подавали завтрак подобным способом», — слегка улыбнувшись, подумала ты.^^";
            if s:has 'open' and s.loc == 'down' then
                p"Он открыт.";
                if #objs'kitchen_lift' == 0 then
                    p "Внутри ничего нет.";
                end;
                mp:content(s);
            else
                p"Он закрыт.";
            end;
            p "С правой стороны от лифта на отдельной панели есть две расположенные одна под другой круглые потёртые кнопки, на них изображены стрелки вверх и вниз соответственно.";
        else
            p "Кухонный лифт.";
            if s:has 'open' and s.loc == 'down' then
                p"Он открыт.";
                if #objs'kitchen_lift' == 0 then
                    p "Внутри ничего нет.";
                end;
                mp:content(s);
            else
                p"Он закрыт.";
            end;
            p "Справа от лифта кнопки вверх и вниз.";
        end;
    end;
    before_Enter = "Он недостаточно большой, чтобы в него забраться.";
    before_Take = "Лифт не представляется возможным вытащить из стены, он жёстко прикреплён к подъёмному механизму.";
    before_Open = function(s)
        if s.loc == 'up' then
            p"Дверца лифта не открывается — похоже, он находится наверху.";
            return true;
        end;
        return false;
    end;
    before_Receive = function (s, i)
        if i ^ 'matches' then
            if _'kitchen_old_man'.received_lighter == true then
                p"Больше деду помощь не нужна.";
            else
                p"Нет, это тебе ещё пригодится. Лучше отдай ему зажигалку, и он будет доволен.";
            end;
            return true;
        end;
        return false;
    end;
    after_Open = function(s)
	p "Ты открываешь дверцу лифта.";
	mp:content(s);
    end;
    after_Close = function(s)
	p "Ты закрываешь дверцу лифта.";
	if (not _'kitchen_old_man'.fed or (_'kitchen_old_man'.mentioned_matches and not _'kitchen_old_man'.received_lighter)) and _'kitchen_old_man'.annoyed then
		_'kitchen_lift'.loc = 'up';
		p"^^«Я устал ждать!» — внезапно рявкает дед, и лифт уезжает наверх.";
	end;
    end;
}:attr 'static,container,openable,~open';

obj {
    -"кнопка вверх,кнопка наверх,кнопка|наверх,вверх";
    nam = "kitchen_button_up";
    description = "Красная круглая кнопка, указывающая наверх.";
    before_Push = function(s)
        if _'kitchen_lift':has 'open' then
            p"Ты нажимаешь кнопку, раздаётся щелчок, но ничего не происходит.";
            return true;
        end;
        if _'kitchen_lift'.loc == 'up' then
            p"Ты нажимаешь кнопку, но ничего не происходит.";
            return true;
        else
            _'kitchen_lift'.loc = 'up';
            if _'kitchen_lift'.used == false then
                p"Ты слышишь, как что-то внутри стен заработало, щёлкнуло, загудело, и лифт томно и неспешно начал свой подъём.";
                _'kitchen_lift'.used = true;
            else
                p"Ты нажимаешь кнопку, и лифт с урчащим звуком уезжает наверх.";
            end;
        end;
    end;
}:attr 'static,concealed';
obj {
    -"кнопка вниз,кнопка|вниз";
    nam = "kitchen_button_down";
    description = "Красная круглая кнопка, указывающая вниз.";
    before_Push = function(s)
        if _'kitchen_lift':has 'open' then
            p"Ты нажимаешь кнопку, раздаётся щелчок, но ничего не происходит.";
            return true;
        end;
        if _'kitchen_lift'.loc == 'down' then
            p"Ты нажимаешь кнопку, но ничего не происходит.";
            return true;
        else
            _'kitchen_lift'.loc = 'down';
            _'kitchen_old_man'.counter_lift_interaction = 0;
            _'kitchen_old_man'.counter_lift_interaction_2 = 0;
            p"Ты нажимаешь кнопку, и лифт возвращается вниз.";
        end;
    end;
}:attr 'static,concealed';

obj {
    -"старик,дед,репродуктор";
    nam = "kitchen_old_man";
    counter = 0;
    counter_lift_interaction = 0;
    counter_lift_interaction_2 = 0;
    counter_since_fed = 0;
    mentioned_matches = false;
    fed = false;
    annoyed = false;
    received_lighter = false;
    told_you_a_story = false;
    description = "Старика здесь нет, он общается с тобой через репродуктор, видимо, из какой-то другой комнаты.";
    before_Default = function(s, ev, w)
        p"Старика здесь нет, он общается с тобой через репродуктор, видимо, из другой комнаты.";
    end;
    ["before_Talk, Ask, AskTo, AskFor, Tell, Answer"] = "Ты пытаешься заговорить с дедом, но он тебя не слышит — связь с ним, увы, односторонняя.";
    ["before_Attack, ThrownAt, Cut, Tear, Shoot"] = "Ты не можешь убить старика, потому что его здесь нет... Да, и ещё потому что ты не убийца!";
	itemReaction = function(s)
		if inside('kitchen_avocado', 'kitchen_lift') or inside('kitchen_avocado_pieces', 'kitchen_lift') or inside('kitchen_bread', 'kitchen_lift') or inside('kitchen_bread_piece', 'kitchen_lift') or inside('kitchen_knife', 'kitchen_lift') then
			return "Намекаешь, чтобы я сам себе готовил бутерброд? Ага, щас!";
		elseif inside('kitchen_candy', 'kitchen_lift') then
			return "Ты думаешь, если бы я сам хотел съесть эту конфету, то отправил бы её тебе?";
		elseif inside('lamp', 'kitchen_lift') or inside('kerosin', 'kitchen_lift') then
			return "У меня тут достаточно светло!";
		elseif inside('flute', 'kitchen_lift') then
			return "И с чего ты решила, что мне не хватает музыки, а?";
		elseif inside('statuetka', 'kitchen_lift') or inside('book', 'kitchen_lift') or inside('dagger', 'kitchen_lift') then
			return "Да ты с ума сошла! Это древние мистические предметы, нельзя их разбрасывать где попало!";
		end
		return false;
	end;
    daemon = function(s)
        if where(pl) ~= _'room6_kitchen' then
            return;
        end;
        s.counter = s.counter + 1;
        if s.counter == 3 then
            p"«Кхе-кхе! Алло?! — раздаётся старческий голос из какого-то невидимого репродуктора. — Там кто-нибудь есть?»";
        elseif s.counter == 4 then
            p"«Не молчи. Я видел, как ты входила в дом. Должно быть, ты моя новая сиделка», — говорит он.";
        elseif s.counter == 6 then
            p"«Слушай, мне плевать, кто ты. Я голоден и требую чтобы ты, паразитка, сейчас же позаботилась об этом. Сделай для меня бутерброд с авокадо и отправь его мне через во-он тот лифт в стене, слышишь?» У тебя создаётся впечатление, что он за тобой наблюдает.";
        elseif s.counter == 7 then
            p"«Эй, я не собираюсь ждать вечно. На кухне есть всё, что тебе потребуется, давай, вперёд, au boulot !» — заканчивает он.";
        end;
        if s.counter > 7 then
            if s.fed == true then
                s.counter_since_fed = s.counter_since_fed + 1;
                if s.counter_since_fed == 3 then
                    if s.annoyed == true then
                        p"«Ладно, хоть какая-то польза от тебя есть».";
                    else
                        p"«Хотел ещё раз поблагодарить тебя за то, что в итоге не отказала в просьбе старику, t'es une fille sage».";
                    end;
                elseif s.counter_since_fed == 4 then
                    s.mentioned_matches = true;
                    if s.annoyed == true then
                        p"«Ещё вот. Мне очень хочется покурить, но спички, как назло, закончились. Поищи где-то в печи и отправь мне, ясно тебе?»";
                    else
                        p"«Однако, постой, ma chérie, тут вновь нужна твоя помощь. Мне очень хочется покурить, но обнаружилось, что у меня закончились спички. Не могла бы ты отправить их мне? Полагаю, ты сможешь найти их где-то рядом с печью».";
                    end;
                end;
                
                if _'kitchen_lift'.loc == 'up' then
                    if s.counter_since_fed > 4 then
                        if s.counter_lift_interaction_2 == 0 then
                            s.counter_lift_interaction_2 = s.counter_lift_interaction_2 + 1;
                            _'kitchen_lift':attr 'open';
                            p"Лифт вновь открывается наверху. «Ну что тут у нас?» — отзывается голос старика.";
                            return;
                        elseif s.counter_lift_interaction_2 == 1 then
                            if #objs'kitchen_lift' == 0 then
                                s.counter_lift_interaction_2 = 100;
                                _'kitchen_lift':attr '~open';
                                if s.annoyed == true then
                                    p "«Опять ты надо мной издеваешься!» — он со злостью захлопывает дверцу лифта со своей стороны.";
                                else
                                    s.annoyed = true;
                                    p"«Что за чёрт побери! Отправь мне чем я смогу прикурить», — он громко закрывает дверь лифта со своей стороны.";
                                end;
                            elseif inside('kitchen_lighter', 'kitchen_lift') then
                                s.counter_lift_interaction_2 = 2;
                                remove 'kitchen_lighter';
                                if s.annoyed then
                                    p "«Ну неужели! Дождался».";
                                else
                                    p "«Молодец! Это сгодится».";
                                end;
                            else
                                s.counter_lift_interaction_2 = 100;
                                _'kitchen_lift':attr '~open';
			        local _reaction = s:itemReaction();
                                if s.annoyed == true then
				    if _reaction then
					p ("«" .. _reaction .. " Опять ты надо мной издеваешься!» — он со злостью захлопывает дверцу лифта со своей стороны.");
				    else
					p "«Опять ты надо мной издеваешься!» — он со злостью захлопывает дверцу лифта со своей стороны.";
				    end
                                else
                                    s.annoyed = true;
				    if _reaction then
					p ("«" .. _reaction .. " Просто отправь мне чем я смогу прикурить», — он громко закрывает дверь лифта со своей стороны.");
				    else
					p"«Что за чёрт побери! Отправь мне чем я смогу прикурить», — он громко закрывает дверь лифта со своей стороны.";
				    end
                                end;
                            end;
                        elseif s.counter_lift_interaction_2 == 2 then
                            s.counter_lift_interaction_2 = 3;
                            _'kitchen_lift':attr '~open';
                            s.received_lighter = true;
                            p "«Так, ну, расскажу тебе теперь байку о хозяйке этого дома».";
                        elseif s.counter_lift_interaction_2 == 3 then
                            s.counter_lift_interaction_2 = 4;
                            p "«Жила она когда-то на улице Весенних Территорий, — не спрашивай, где это, — в семейном коттедже. На тот момент было у неё два мужичка. Они, то есть два мужичка, были, по своей натуре, людьми неприхотливыми. Все трое жили хорошо, дружно, душа в душу. Если бы не одна неудобная, но в общем-то мелкая на первый взгляд вещь. У хозяйки было странное хобби. Она коллекционировала каштаны. Была просто помешана на каштанах».";
                        elseif s.counter_lift_interaction_2 == 4 then
                            s.counter_lift_interaction_2 = 5;
                            p "«…И когда мужички пытались ей намекнуть на то, что она чрезмерно увлеклась своим хобби, — ведь к тому моменту каштанами был завален весь дом, их можно было найти в каждом шкафчике, в каждой комнате — и что собирать каштаны — это глупо, в ответ она лишь смеялась и говорила, что просто любит каштаны за их форму, за то, что они успокаивают, когда ты держишь их в руке. С её точки зрения, каштаны были даже важнее, чем шампанское, и поэтому она тратила огромные суммы на путешествия по всей стране, в поисках мест, где она ещё их не собирала. А стол вот этот кухонный, он здесь как раз из того дома, с улицы Весенних Территорий».";
                        elseif s.counter_lift_interaction_2 == 5 then
                            s.counter_lift_interaction_2 = 6;
                            s.told_you_a_story = true;
                            p "«…На нем лежали много разных каштанов, от самых мелких до крупных и экзотических. И временами она их собирала и подолгу разглядывала. И в эти моменты на её лице появлялось какое-то странное выражение. А потом она подходила к окну и тихо плакала. Никто так и не знает о причинах столь странного её поведения. Иногда она проводила с ними так много времени, что могла заснуть прямо на полу, под этим самым столом. И вот однажды она рассказала нам, что, проснувшись, неожиданно для себя обнаружила, что под столом выжжены имена мастеров данного труда, но, честно говоря, за столько лет я так и не проверил это. Но, возможно, это будет сделать интересно тебе. Спасибо, что послушала эту небольшую историю».";
                            DaemonStop('kitchen_old_man');
                        end;
                    end;
		else
		    if not s.received_lighter and (s.counter_since_fed % 15) == 0 then
			p "«Я всё ещё жду спички, они должны быть рядом с печью», — напоминает старик.";
		    end;
                end;
                return;
            end;
            if _'kitchen_lift'.loc == 'up' then
                if s.fed == false then
                    if s.counter_lift_interaction == 0 then
                        s.counter_lift_interaction = s.counter_lift_interaction + 1;
                        _'kitchen_lift':attr 'open';
                        p"Ты слышишь, как лифт открывается где-то наверху. «Так, что это тут?» — доносится эхом по шахте.";
                        return;
                    elseif s.counter_lift_interaction == 1 then
                        if #objs'kitchen_lift' == 0 then
                            s.counter_lift_interaction = 100;
                            _'kitchen_lift':attr '~open';
                            s.annoyed = true;
                            p "«Что? Но здесь ничего нет, чертовка!» — ты слышишь, как он с грохотом закрывает дверцу лифта.";
                        elseif inside('kitchen_sandwich', 'kitchen_lift') then
                            s.counter_lift_interaction = 2;
                            remove 'kitchen_sandwich';
                            if s.annoyed then
                                p "«Ну наконец-то, бутерброд с авокадо».";
                            else
                                p "«О, то что надо! Спасибо, наверное».";
                            end;
                        else
                            s.counter_lift_interaction = 100;
                            _'kitchen_lift':attr '~open';
                            s.annoyed = true;
			    local _reaction = s:itemReaction();
			    if _reaction then
				p ("«" .. _reaction .. " Ты издеваешься?» — он злобно захлопывает дверцу лифта.");
			    else
				p "«Что это такое? Ты издеваешься?» — он злобно захлопывает дверцу лифта.";
			    end
                        end;
                    elseif s.counter_lift_interaction == 2 then
                        move('kitchen_candy', 'kitchen_lift');
                        _'kitchen_lift':attr '~open';
                        _'kitchen_lift'.loc = 'down';
                        p "«Спасибо, было вполне себе сносно. Полагаю, проявленная тобою забота заслуживает соразмерной награды, хе-хе», — он захлопывает дверцу лифта и отправляет его вниз.";
			s.counter_lift_interaction = 3;
                        s.fed = true;
                        mp.score=mp.score+1;
                    end;
                end;
	    else
		if not s.fed and (s.counter % 15) == 0 then
			p "«Я всё ещё жду свой бутерброд с авокадо», — напоминает старик.";
		end;
            end;
        end;
    end;
}:attr 'animate,concealed';

obj {
    -"конфетка,конфета";
    nam = "kitchen_candy";
    description = "Если бы не растаявший шоколад, просочившийся сквозь выцветшую обёртку, то отнести данную субстанцию к когда-то бывшей конфете, пришедшей к нам, видимо, прямиком из СССР, было бы практически невозможно. Отвратительно.";
    after_Eat = function(s)
        p"Ты начинаешь медленно отрывать обёртку от смеси шоколада, ореховой крошки и кремовой прослойки. Кусок за куском. Затем ногтями выковыриваешь те остатки бумаги, которые возможно. Руки становятся липкими, стремительно покрываются шоколадными следами. Создаётся ощущение, что от этого уже невозможно будет отмыться. Наконец, то, что когда-то было конфетой, обнажило все свои слои и освободилось от упаковки.^^\
            Ты медленно подводишь лакомство к лицу, всматриваешься, ловишь носом сладковатый аромат; тут изображение плывёт, глаза автоматически прикрываются… сознание возвращается, ты стоишь в центре кухни, продолжая смотреть на свою ладонь, только конфеты там больше нету. По характерному привкусу во рту ты понимаешь, что ты сделала вскоре после помутнения сознания, понимаешь, но отказываешься верить в произошедшее."; 
        if _'kitchen_cat'.seen == true then
            p"^^Ты вспоминаешь о коте за окном. А ведь можно было просто… отдать конфету ему!";
        end;
        mp.score=mp.score+1;
    end;
}:attr 'edible';

obj {
    -"окно";
    nam = "kitchen_window";
    description = "Окно приоткрыто. За ним виднеется лужайка, а поодаль высится лес.";
    before_Open = "Окно и так уже приоткрыто.";
    before_Close = "Сегодня тёплый день, ни к чему закрывать окно.";
}:attr 'static,concealed';
obj {
    -"лужайка";
    nam = "kitchen_grass";
    description = function(s)
        if inside('kitchen_cat', 'room6_kitchen') then
            p"Ты видишь, как на лужайке под солнцем развалился белый кот.";
        else
            p"Солнце освещает лужайку, но кота и след простыл.";
        end;
    end
}:attr 'static,concealed';

obj {
    -"кот,котик|бабочка";
    seen = false;
    nam = "kitchen_cat";
    description = "Беззаботный белый котик с рыжими пятнами. На шее у него висит чёрная бабочка. Признаться, тебе хотелось бы быть им, а не решать загадки этого дома.";
    before_Default = function(s, ev, w)
        s.seen = true;
        if ev == 'Exam' then
            return false;
        end;
        p"Не стоит беспокоить котика без причины.";
    end;
    before_ThrownAt = function(s, w)
	mp:xaction("Give", w, s);
    end;
    life_Give = function(s, w)
        if w ^ "kitchen_candy" then
            p"Ты бросаешь конфету за окошку коту. Он игриво хватает конфету и убегает с ней в лес.";
            remove 'kitchen_candy';
            remove 'kitchen_cat';
            mp.score=mp.score+1;
        else
	    s.seen = true;
            p"Это не нужно давать коту, может, попробовать что-то другое?";
        end;
    end;
	before_Take = function(s)
		s.seen = true;
		p 'Я ПРОСТО ПРИШЕЛ ЗАБРАТЬ СВОЕГО КОТА... А, стоп, это не та игра.'
	end;
	before_Tell = function(s, w)
		s.seen = true;
		if w:find "мяу" or w:find "мур" or w:find "кис" or w:find "гав" then
			p 'Кот посмотрел на тебя с презрением.'
		else
			p 'Кот потягивается на солнышке. Ему не до тебя.'
		end
	end;
	before_Shoot = function(s, w)
		s.seen = true;
		if not w and pl:have('gun') then
			w = _'gun';
		end
		if(w == _'gun') then
			p 'ДА ЧТО ТЫ ЗА МОНСТР??? Ты полностью заслуживаешь того, что с тобой сейчас произойдёт!'
		else
			p 'Котеньку?!!! К счастью, ты не вооружена.'
		end;
	end;
}:attr 'static,concealed,animate';
obj {
    -"лес";
    nam = "kitchen_forest";
    description = "Ты видишь непроглядный лес.";
}:attr 'static,concealed';
obj {
    -"стены";
    nam = "kitchen_walls";
    description = "Стены, покрытые оранжевой краской.";
	before_Cut = function(s,w)
		if w and mp:check_held(w) then
			return
		end
		if w == _'dagger' or w == _'kitchen_knife' then
			p "Ты хочешь вырезать на стене неприличное слово, но вовремя вспоминаешь, что уже вышла из дошкольного возраста.";
		else
			return false
		end
	end;
}:attr 'static,concealed';
obj {
    -"потолок";
    nam = "kitchen_ceiling";
    description = "Потолок высотой примерно четыре метра. Местами в углу паутина, где-то чёрные пятна копоти от печи. В целом, всё, что ожидаешь увидеть в подобном месте.";
}:attr 'static,concealed';

obj {
    -"печь/жр|горнило,подпечье";
    dsc = "Справа от лифта находится печь.";
    nam = "kitchen_pec";
    searched = false;
    description = function(s)
        if _'kitchen_old_man'.mentioned_matches == true then
            if s.searched == false then
                s.searched = true;
                move('matches', me());
                move('kitchen_lighter', me());
                mp.score=mp.score+1;
                p"Ты обыскиваешь горнило и находишь спички и зажигалку. Ты забираешь их себе.";
            else
                p"Больше в печи ничего нет.";
            end;
        else
            p"Печь как печь. Стенки, горнило и подпечье, забитое дровами.";
        end;
    end;
    before_Burn = "У тебя нет времени или необходимости разводить огонь.";
}:attr 'static';

obj {
    -"зажигалка";
    nam = "kitchen_lighter";
    description = "Зажигалка. На дне ещё есть немного газа.";
        before_Burn = function(s,w)
             p "Зажигалка горит слабым огоньком. Света от неё, впрочем, недостаточно, чтобы хоть что-то осветить.";
        end
}:attr '';

obj {
    -"спички|спичка";
    nam = "matches";
    description = "Коробок спичек. Осталась всего одна.";
        before_Burn = function(s,w)
             p "Не стоит просто так сжигать последнюю спичку.";
        end;
}
