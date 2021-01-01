package main

import (
    "fmt"
    "os/exec"
)

func main() {

    prg := "pwd"

    cmd := exec.Command(prg)
    stdout, err := cmd.Output()

    if err != nil {
        fmt.Println(err.Error())
        return
    }

    fmt.Print(string(stdout))
}
