# RISC-V Educational Core – ISA v0

## 1. Objetivo de la ISA v0

La ISA v0 define el **conjunto mínimo de instrucciones** necesario para construir y comprender un procesador RISC-V funcional desde un punto de vista **académico**.

Los objetivos principales son:

* Entender el datapath completo de un procesador
* Relacionar instrucciones con bloques hardware concretos
* Facilitar la verificación paso a paso
* Permitir escalabilidad futura sin romper compatibilidad conceptual

Esta ISA **no pretende ser completa**, sino **didáctica y extensible**.

---

## 2. Parámetros globales

| Parámetro  | Valor   | Descripción             |
| ---------- | ------- | ----------------------- |
| XLEN       | 32      | Ancho de palabra        |
| Registros  | 8       | x0–x7                   |
| Endianness | Little  | Compatible RISC-V       |
| PC         | 32 bits | Direccionamiento lineal |

Notas:

* Aunque solo existen 8 registros físicos, los campos rs/rd siguen siendo de 5 bits
* x0 está cableado a cero

---

## 3. Instrucciones soportadas

### 3.1 Aritmética

| Instrucción | Tipo | Descripción           |
| ----------- | ---- | --------------------- |
| add         | R    | Suma entre registros  |
| sub         | R    | Resta entre registros |
| addi        | I    | Suma con inmediato    |

### 3.2 Memoria

| Instrucción | Tipo | Descripción      |
| ----------- | ---- | ---------------- |
| lw          | I    | Carga palabra    |
| sw          | S    | Almacena palabra |

### 3.3 Control de flujo

| Instrucción | Tipo | Descripción                  |
| ----------- | ---- | ---------------------------- |
| beq         | B    | Branch si rs1 == rs2         |
| jal         | J    | Salto incondicional con link |

---

## 4. Semántica de las instrucciones

### add rd, rs1, rs2

```
rd ← rs1 + rs2
pc ← pc + 4
```

### sub rd, rs1, rs2

```
rd ← rs1 - rs2
pc ← pc + 4
```

### addi rd, rs1, imm

```
rd ← rs1 + signext(imm)
pc ← pc + 4
```

### lw rd, imm(rs1)

```
addr = rs1 + signext(imm)
rd ← MEM[addr]
pc ← pc + 4
```

### sw rs2, imm(rs1)

```
addr = rs1 + signext(imm)
MEM[addr] ← rs2
pc ← pc + 4
```

### beq rs1, rs2, imm

```
if (rs1 == rs2)
  pc ← pc + signext(imm)
else
  pc ← pc + 4
```

### jal rd, imm

```
rd ← pc + 4
pc ← pc + signext(imm)
```

---

## 5. Formatos de instrucción

### R-Type

```
funct7 | rs2 | rs1 | funct3 | rd | opcode
```

### I-Type

```
imm[11:0] | rs1 | funct3 | rd | opcode
```

### S-Type

```
imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode
```

### B-Type

```
imm[12|10:5] | rs2 | rs1 | funct3 | imm[4:1|11] | opcode
```

### J-Type

```
imm[20|10:1|11|19:12] | rd | opcode
```

---

## 6. Extracción de inmediatos

* Todos los inmediatos se **sign-extienden** a 32 bits
* Los inmediatos B y J están alineados a 2 bytes (bit 0 = 0)

---

## 7. Comportamiento no soportado (decisiones conscientes)

Esta versión de la ISA **no implementa**:

* Instrucciones ilegales
* Excepciones
* Interrupciones
* Accesos desalineados
* CSRs

Estas ausencias son **decisiones pedagógicas**, no limitaciones técnicas.

---

## 8. Escalabilidad futura

La ISA v0 está diseñada para evolucionar hacia:

* RV32I completo
* Más registros
* Pipeline
* CSR y modos de privilegio
* Verificación avanzada

Sin necesidad de redefinir los conceptos básicos.

---

## 9. Relación con la microarquitectura

Cada instrucción de la ISA v0 activa explícitamente:

* Lectura de registros
* Operaciones ALU
* Accesos a memoria
* Actualización de PC

Esto permite una correspondencia **1:1** entre:

> Instrucción → Señales → Bloques hardware

Que es el objetivo central de este proyecto educativo.
