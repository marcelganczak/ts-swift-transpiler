const units = {
    temperature: {
        C: {
            isBase: "true",
            toBase: (val:number):number => val,
            fromBase: (val:number):number => val
        },
        F: {
            isBase: "false",
            toBase: (val:number):number => val * 5 / 9 + 32,
            fromBase: (val:number):number => val * 9 / 5 + 32
        }
    }
}