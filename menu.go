package main

import (
    "fmt"
    "os"
    "os/exec"
    "runtime"
    "time"
)

var clear map[string]func() //create a map for storing clear funcs

func init() {
    clear = make(map[string]func()) //Initialize it
    clear["linux"] = func() { 
        cmd := exec.Command("clear") //Linux example, its tested
        cmd.Stdout = os.Stdout
        cmd.Run()
    }
    clear["windows"] = func() {
        cmd := exec.Command("cmd", "/c", "cls") //Windows example, its tested 
        cmd.Stdout = os.Stdout
        cmd.Run()
    }
}

func CallClear() {
    value, ok := clear[runtime.GOOS] //runtime.GOOS -> linux, windows, darwin etc.
    if ok { //if we defined a clear func for that platform:
        value()  //we execute it
    } else { //unsupported platform
        panic("Your platform is unsupported! I can't clear terminal screen :(")
    }
}


func main() {
	berhentii:
    for true {
    	var text int = 0.0
    	CallClear()
    	fmt.Println("        Litegapps Menu")
    	fmt.Println(" ")
    	fmt.Println("1.make")
    	fmt.Println("2.clean")
    	fmt.Println("3.about")
    	fmt.Println("4.exit")
    	fmt.Println(" ")
		fmt.Print("Enter text: ")
		fmt.Scanln(&text)
		switch text {
			case 1:
			cmd := exec.Command("sh", "pwd")Output()
			time.Sleep(3 * time.Second)
			case 2:
			fmt.Println("2")
			time.Sleep(3 * time.Second)
			case 3:
			fmt.Println("3")
			time.Sleep(3 * time.Second)
			case 4:
				break berhentii
			default:
			fmt.Println("Error selected")
			time.Sleep(2 * time.Second)
    	 }
    	}
}
