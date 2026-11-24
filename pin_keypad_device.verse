using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ======================================================
#  Advanced PIN keypad for UEFN
#  Code by: AZ ALSAYYED
#  Original code, written from scratch.
# ======================================================

# One valid code. Add as many as you want in the device's "Codes" list.
passcode_entry := class<concrete>:
    @editable Label : string = "Code"
    @editable PIN : string = "1234"
    @editable OnSuccess : ?trigger_device = false
    @editable Reward : ?accolades_device = false
    @editable OnlyOnce : logic = false
    var Used : logic = false

# Everything we remember about one player's keypad.
player_keypad := class:
    Canvas : canvas
    Display : text_block
    Status : text_block
    var Entered : string = ""
    var Failures : int = 0
    var LockedUntil : float = 0.0
    var IsOpen : logic = false

pin_keypad_device := class(creative_device):

    # --- Devices ---
    @editable OpenButtons : []button_device = array{}
    @editable DefaultSuccess : trigger_device = trigger_device{}
    @editable OnFail : trigger_device = trigger_device{}
    @editable OnLockout : trigger_device = trigger_device{}

    # --- Codes ---
    @editable Codes : []passcode_entry = array{}

    # --- Rules ---
    @editable Title : string = "KEYPAD"
    @editable MaxDigits : int = 6
    @editable MaxAttempts : int = 3
    @editable LockoutSeconds : float = 15.0
    @editable HideDigits : logic = true

    # --- Look ---
    @editable AccentColor : color = GreenYellow
    @editable PanelColor : color = MakeColorFromHex("#101418")

    var Sessions : [agent]player_keypad = map{}

    ToMsg<localizes>(S:string):message = "{S}"

    OnBegin<override>()<suspends>:void =
        for (Btn : OpenButtons):
            Btn.InteractedWithEvent.Subscribe(OnOpenPressed)

    # ---------- Opening and closing ----------

    OnOpenPressed(A:agent):void =
        if (P := player[A], UI := GetPlayerUI[P]):
            if (Existing := Sessions[A]):
                if (Existing.IsOpen = false):
                    ShowSession(UI, Existing)
            else:
                NewSession := BuildSession()
                if (set Sessions[A] = NewSession):
                    ShowSession(UI, NewSession)

    ShowSession(UI:player_ui, S:player_keypad):void =
        set S.Entered = ""
        RefreshDisplay(S)
        if (GetSimulationElapsedTime() < S.LockedUntil):
            SetStatus(S, "Locked - try again soon", Red)
        else:
            SetStatus(S, "Enter code", White)
        UI.AddWidget(S.Canvas, player_ui_slot{InputMode := ui_input_mode.All})
        set S.IsOpen = true

    CloseSession(P:player):void =
        if (S := Sessions[P], UI := GetPlayerUI[P]):
            UI.RemoveWidget(S.Canvas)
            set S.IsOpen = false
            set S.Entered = ""

    # ---------- Building the UI ----------

    BuildSession():player_keypad =
        Display := text_block{DefaultText := ToMsg(""), DefaultTextColor := AccentColor}
        Status := text_block{DefaultText := ToMsg("Enter code"), DefaultTextColor := White}
        TitleText := text_block{DefaultText := ToMsg(Title), DefaultTextColor := White}

        B0 := button_loud{DefaultText := ToMsg("0")}
        B0.OnClick().Subscribe(Press0)
        B1 := button_loud{DefaultText := ToMsg("1")}
        B1.OnClick().Subscribe(Press1)
        B2 := button_loud{DefaultText := ToMsg("2")}
        B2.OnClick().Subscribe(Press2)
        B3 := button_loud{DefaultText := ToMsg("3")}
        B3.OnClick().Subscribe(Press3)
        B4 := button_loud{DefaultText := ToMsg("4")}
        B4.OnClick().Subscribe(Press4)
        B5 := button_loud{DefaultText := ToMsg("5")}
        B5.OnClick().Subscribe(Press5)
        B6 := button_loud{DefaultText := ToMsg("6")}
        B6.OnClick().Subscribe(Press6)
        B7 := button_loud{DefaultText := ToMsg("7")}
        B7.OnClick().Subscribe(Press7)
        B8 := button_loud{DefaultText := ToMsg("8")}
        B8.OnClick().Subscribe(Press8)
        B9 := button_loud{DefaultText := ToMsg("9")}
        B9.OnClick().Subscribe(Press9)

        DelBtn := button_regular{DefaultText := ToMsg("DEL")}
        DelBtn.OnClick().Subscribe(OnDelete)
        OkBtn := button_regular{DefaultText := ToMsg("OK")}
        OkBtn.OnClick().Subscribe(OnEnter)
        CancelBtn := button_quiet{DefaultText := ToMsg("Cancel")}
        CancelBtn.OnClick().Subscribe(OnCancel)

        Row1 : []widget = array{B1, B2, B3}
        Row2 : []widget = array{B4, B5, B6}
        Row3 : []widget = array{B7, B8, B9}
        Row4 : []widget = array{DelBtn, B0, OkBtn}
        Row5 : []widget = array{CancelBtn}

        DisplayBox := overlay:
            Slots := array:
                overlay_slot:
                    Widget := color_block{DefaultColor := Black, DefaultOpacity := 0.8, DefaultDesiredSize := vector2{X := 360.0, Y := 56.0}}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                overlay_slot:
                    Widget := Display
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center

        Panel := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot{Widget := TitleText, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 12.0}}
                stack_box_slot{Widget := DisplayBox, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 8.0}}
                stack_box_slot{Widget := Status, HorizontalAlignment := horizontal_alignment.Center, Padding := margin{Bottom := 16.0}}
                stack_box_slot{Widget := MakeRow(Row1), HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 8.0, Bottom := 8.0}}
                stack_box_slot{Widget := MakeRow(Row2), HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 8.0, Bottom := 8.0}}
                stack_box_slot{Widget := MakeRow(Row3), HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 8.0, Bottom := 8.0}}
                stack_box_slot{Widget := MakeRow(Row4), HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 8.0, Bottom := 8.0}}
                stack_box_slot{Widget := MakeRow(Row5), HorizontalAlignment := horizontal_alignment.Fill, Padding := margin{Top := 16.0}}

        MyCanvas := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block{DefaultColor := PanelColor, DefaultOpacity := 0.92, DefaultDesiredSize := vector2{X := 420.0, Y := 620.0}}
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin{Top := 20.0, Bottom := 20.0, Left := 20.0, Right := 20.0}
                                Widget := Panel

        return player_keypad{Canvas := MyCanvas, Display := Display, Status := Status}

    MakeRow(Items:[]widget):stack_box =
        var RowSlots : []stack_box_slot = array{}
        for (W : Items):
            set RowSlots += array{stack_box_slot{Widget := W, Distribution := option{1.0}, HorizontalAlignment := horizontal_alignment.Center, VerticalAlignment := vertical_alignment.Center, Padding := margin{Left := 10.0, Right := 10.0}}}
        return stack_box{Orientation := orientation.Horizontal, Slots := RowSlots}

    # ---------- Display helpers ----------

    SetStatus(S:player_keypad, Text:string, C:color):void =
        S.Status.SetText(ToMsg(Text))
        S.Status.SetTextColor(C)

    Mask(Count:int):string =
        var Out : string = ""
        if (Count > 0):
            for (I := 1..Count):
                set Out += "●"
        return Out

    RefreshDisplay(S:player_keypad):void =
        if (HideDigits?):
            S.Display.SetText(ToMsg(Mask(S.Entered.Length)))
        else:
            S.Display.SetText(ToMsg(S.Entered))

    # ---------- Button handlers ----------

    Press0(WM:widget_message):void = AddDigit(0, WM.Player)
    Press1(WM:widget_message):void = AddDigit(1, WM.Player)
    Press2(WM:widget_message):void = AddDigit(2, WM.Player)
    Press3(WM:widget_message):void = AddDigit(3, WM.Player)
    Press4(WM:widget_message):void = AddDigit(4, WM.Player)
    Press5(WM:widget_message):void = AddDigit(5, WM.Player)
    Press6(WM:widget_message):void = AddDigit(6, WM.Player)
    Press7(WM:widget_message):void = AddDigit(7, WM.Player)
    Press8(WM:widget_message):void = AddDigit(8, WM.Player)
    Press9(WM:widget_message):void = AddDigit(9, WM.Player)

    AddDigit(Digit:int, P:player):void =
        if (S := Sessions[P], S.Entered.Length < MaxDigits, GetSimulationElapsedTime() >= S.LockedUntil):
            set S.Entered += "{Digit}"
            RefreshDisplay(S)

    OnDelete(WM:widget_message):void =
        if (S := Sessions[WM.Player], S.Entered.Length > 0, Shorter := S.Entered.Slice[0, S.Entered.Length - 1]):
            set S.Entered = Shorter
            RefreshDisplay(S)

    OnCancel(WM:widget_message):void =
        CloseSession(WM.Player)

    OnEnter(WM:widget_message):void =
        P := WM.Player
        if (S := Sessions[P]):
            Now := GetSimulationElapsedTime()
            if (Now < S.LockedUntil):
                if (Left := Ceil[S.LockedUntil - Now]):
                    SetStatus(S, "Locked - wait {Left}s", Red)
                return
            if (S.Entered.Length = 0):
                SetStatus(S, "Type a code first", Orange)
                return
            if (Code := FindMatch(S.Entered)?):
                HandleSuccess(P, S, Code)
            else:
                HandleFailure(P, S)

    # ---------- Logic ----------

    FindMatch(Input:string):?passcode_entry =
        for (Code : Codes):
            if (Code.PIN = Input, not (Code.OnlyOnce? and Code.Used?)):
                return option{Code}
        return false

    HandleSuccess(P:player, S:player_keypad, Code:passcode_entry):void =
        set S.Failures = 0
        if (Code.OnlyOnce?):
            set Code.Used = true
        if (T := Code.OnSuccess?):
            T.Trigger(P)
        else:
            DefaultSuccess.Trigger(P)
        if (R := Code.Reward?):
            R.Award(P)
        CloseSession(P)

    HandleFailure(P:player, S:player_keypad):void =
        set S.Failures += 1
        OnFail.Trigger(P)
        set S.Entered = ""
        RefreshDisplay(S)
        if (S.Failures >= MaxAttempts):
            set S.Failures = 0
            set S.LockedUntil = GetSimulationElapsedTime() + LockoutSeconds
            OnLockout.Trigger(P)
            SetStatus(S, "Too many tries - locked", Red)
        else:
            Left := MaxAttempts - S.Failures
            SetStatus(S, "Wrong code ({Left} left)", Red)
