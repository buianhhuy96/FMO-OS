package screen

import (
	"time"

	"github.com/pterm/pterm"
	"github.com/pterm/pterm/putils"
)

func (m ScreensMethods) WelcomeScreen() {
	area, _ := pterm.DefaultArea.WithCenter().WithCenter().Start()
	for i := 0; i < 2; i++ {
		str, _ := pterm.DefaultBigText.WithLetters(
			putils.LettersFromStringWithStyle("G", pterm.FgLightGreen.ToStyle()),
			putils.LettersFromString("haf")).
			Srender()
		area.Update(str)
		time.Sleep(time.Second)
	}
	goToNextScreen()
	return
}

func (m ScreensMethods) WelcomeScreenHeading() string {
	return "Welcome"
}
