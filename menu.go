package main

import (
    "fmt" 
    "bufio" 
    "os"
    "os/exec"
    "runtime"
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
    for true {
    	CallClear()
    	fmt.Println("      Litegapps Menu")
    	fmt.Println(" ")
    	fmt.Println("1.make")
    	fmt.Println("2.clean")
    	fmt.Println("3.about")
    	fmt.Println("4.exit")
    	fmt.Println(" ")
    	reader := bufio.NewReader(os.Stdin)
		fmt.Print(" Select Menu : ")
		text, _ := reader.ReadString('\n')
		if text == 1 {
				fmt.Println("1.make")
			}
    	if else text == 2 {
    		fmt.Println("1.make")
    	}
    	if else text == 3 {
    		fmt.Println("1.make")
    	}
		if else text == 4 {
    		fmt.Println("1.make")
    	}
		else {
			fmt.Println("1.make")
    	}
}
