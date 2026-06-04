# Contributing to RV32IM 5-Stage Pipelined Processor

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** thoroughly
6. **Submit** a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/RV32IM-5Stage-Pipelined-Processor-with-AI-Extensions.git
cd RV32IM-5Stage-Pipelined-Processor-with-AI-Extensions

# Create a feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "Add descriptive commit message"
git push origin feature/your-feature-name
```

## Code Style Guidelines

### Verilog/SystemVerilog

- Use consistent indentation (2 or 4 spaces)
- Follow RISC-V naming conventions
- Add comments for complex logic
- Use meaningful signal/register names
- Follow this structure:

```verilog
// Module declaration with clear port definitions
module module_name (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] input_data,
    output wire [31:0] output_data
);

    // Parameter declarations
    parameter WIDTH = 32;

    // Internal signal declarations
    wire [WIDTH-1:0] internal_signal;

    // Combinational logic
    always @(*) begin
        // Logic here
    end

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            // Reset logic
        end else begin
            // Sequential logic
        end
    end

endmodule
```

### Documentation

- Use clear, concise English
- Add inline comments for non-obvious logic
- Document module interfaces thoroughly
- Include references to RISC-V specification

## Testing Requirements

Before submitting a pull request:

### 1. Simulation Testing
```bash
# Run comprehensive simulation
cd Code
vsim -c processor_tb -do "run -all; quit"
```

### 2. Test Coverage
- [ ] All affected instructions tested
- [ ] Hazard scenarios validated
- [ ] Branch resolution verified
- [ ] Data forwarding confirmed
- [ ] Memory operations checked

### 3. Waveform Analysis
- Verify signal transitions
- Check hazard detection triggers
- Validate forwarding paths
- Confirm memory timing

## Types of Contributions

### Bug Fixes
- Include a clear description of the bug
- Reference any related issues
- Provide before/after waveforms if applicable
- Test fix with existing testbenches

### New Features
- Propose feature in an issue first
- Keep changes focused and modular
- Add corresponding testbench updates
- Update documentation

### Documentation Improvements
- Correct typos and clarify explanations
- Add examples for complex features
- Update diagrams if needed
- Reference authoritative sources

### Performance Improvements
- Benchmark changes if applicable
- Maintain functionality
- Update synthesis metrics if changed
- Document optimization rationale

## Pull Request Process

1. **Update** the README.md with any new features or changes
2. **Run** simulation tests and verify all pass
3. **Include** waveform screenshots for significant logic changes
4. **Reference** any related issues
5. **Write** a clear PR description explaining:
   - What changes were made
   - Why changes were needed
   - How to test the changes
   - Any performance impact

### PR Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Enhancement
- [ ] Documentation update

## Testing Done
- [ ] Simulation passed
- [ ] Testbench coverage verified
- [ ] Waveform analysis completed

## Related Issues
Fixes #(issue number)

## Screenshots/Waveforms
(If applicable, attach simulation waveforms)

## Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Changes verified in simulation
```

## Naming Conventions

### Signals & Registers
```verilog
// Cascaded signals (pipeline registers)
reg [31:0] if_id_inst;      // Instruction from IF stage
reg [31:0] id_ex_alu_result; // ALU result from ID stage
reg [31:0] ex_mem_data;      // Data from EX stage

// Control signals
wire hazard_detected;
wire forwarding_enable;
wire data_from_mem;
```

### Modules
```verilog
// Follow chip hierarchy naming
alu_32bit
hazard_detection_unit
forwarding_unit
pipeline_control_unit
ai_execution_unit
```

## Commit Message Guidelines

```
[AREA] Brief description (50 chars max)

Detailed explanation of changes (if needed)
- Point 1
- Point 2

Fixes #123
```

### Commit Message Prefixes
- `[RTL]` - Core RTL changes
- `[TB]` - Testbench updates
- `[DOC]` - Documentation
- `[SYNTH]` - Synthesis-related
- `[FIX]` - Bug fixes
- `[FEAT]` - New features

## Issue Reporting

When reporting issues:
1. **Use** a clear, descriptive title
2. **Describe** the expected vs actual behavior
3. **Include** simulation waveforms if applicable
4. **Provide** minimal test case
5. **Specify** tool versions used (QuestaSim, DC version, etc.)

### Issue Template

```markdown
## Description
Clear description of the issue

## Steps to Reproduce
1. Do this
2. Then this
3. Result...

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Waveform/Screenshot
(Attach relevant simulation output)

## Environment
- Tool: QuestaSim 2023.4
- SystemVerilog Standard: IEEE 1800-2017
- OS: Linux/Windows
```

## Review Process

All submissions will be reviewed for:
- ✅ Code quality and style
- ✅ Correctness and functionality
- ✅ Test coverage
- ✅ Documentation completeness
- ✅ Performance impact
- ✅ RISC-V specification compliance

## Questions?

- Check existing issues and documentation
- Open a discussion in GitHub Discussions
- Review the architecture documentation in `ARCHITECTURE.md`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to making this processor design excellent!** 🎉
