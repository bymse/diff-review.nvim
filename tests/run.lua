local categories = {
  unit = true,
  integration = true,
  functional = true,
}

local accepted_categories = "unit, integration, functional"

local function configuration_error(message)
  error("Test configuration error: " .. message, 0)
end

local function load_module(module_name)
  local loaded, module_or_error = pcall(require, module_name)
  if not loaded then
    configuration_error(string.format("could not load %q:\n%s", module_name, module_or_error))
  end

  return module_or_error
end

local function validate_registry(category, registry)
  if type(registry) ~= "table" then
    configuration_error(string.format("registry %q must return an array of module names", category))
  end

  local count = 0
  for index, module_name in pairs(registry) do
    if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
      configuration_error(string.format("registry %q must be an array of module names", category))
    end

    if type(module_name) ~= "string" or module_name == "" then
      configuration_error(string.format("registry %q contains an invalid module name", category))
    end

    count = count + 1
  end

  if count == 0 then
    configuration_error(string.format("registry %q must not be empty", category))
  end

  for index = 1, count do
    if registry[index] == nil then
      configuration_error(string.format("registry %q must be an array of module names", category))
    end
  end
end

local function collect_tests(category)
  local registry = load_module(category)
  validate_registry(category, registry)

  local tests = {}
  local test_names = {}

  for _, module_name in ipairs(registry) do
    local test_module = load_module(module_name)
    if type(test_module) ~= "table" then
      configuration_error(string.format("test module %q must return a table of test functions", module_name))
    end

    for test_name, test in pairs(test_module) do
      if type(test_name) ~= "string" or test_name == "" then
        configuration_error(string.format("test module %q contains an invalid test name", module_name))
      end

      if type(test) ~= "function" then
        configuration_error(string.format("test %q in module %q must be a function", test_name, module_name))
      end

      if tests[test_name] then
        configuration_error(string.format("duplicate test name %q", test_name))
      end

      tests[test_name] = test
      table.insert(test_names, test_name)
    end
  end

  table.sort(test_names)
  return tests, test_names
end

local function parse_category()
  if #arg ~= 1 or not categories[arg[1]] then
    error("Expected exactly one category: " .. accepted_categories, 0)
  end

  return arg[1]
end

local category = parse_category()
local tests, test_names = collect_tests(category)
local failures = {}

for _, test_name in ipairs(test_names) do
  local passed, traceback = xpcall(tests[test_name], debug.traceback)
  if passed then
    print(string.format("PASS %s:%s", category, test_name))
  else
    print(string.format("FAIL %s:%s", category, test_name))
    table.insert(failures, string.format("%s:%s\n%s", category, test_name, traceback))
  end
end

if #failures > 0 then
  error(table.concat(failures, "\n\n"), 0)
end

print(string.format("PASS %s %d tests", category, #test_names))
