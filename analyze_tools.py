import re

def extract_tools(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Extract tools from the YAML frontmatter
    tools_match = re.search(r'tools:\s*\[(.*?)\]', content, re.DOTALL)
    if tools_match:
        tools_str = tools_match.group(1)
        # Remove quotes and whitespace, split by comma
        tools = [tool.strip().strip("'\"") for tool in tools_str.split(',') if tool.strip()]
        return set(tools)
    return set()

# Extract tools from each mode
ask_tools = extract_tools('copilot/modes/Ask.chatmode.md')
plan_tools = extract_tools('copilot/modes/Plan.chatmode.md')
review_tools = extract_tools('copilot/modes/Review.chatmode.md')
code_tools = extract_tools('copilot/modes/Code.chatmode.md')

print(f'Ask tools count: {len(ask_tools)}')
print(f'Plan tools count: {len(plan_tools)}')
print(f'Review tools count: {len(review_tools)}')
print(f'Code tools count: {len(code_tools)}')

print('\n=== TOOLS IN PLAN BUT NOT IN CODE ===')
plan_not_code = plan_tools - code_tools
for tool in sorted(plan_not_code):
    print(f'  {tool}')

print(f'\nCount: {len(plan_not_code)}')

print('\n=== TOOLS IN REVIEW BUT NOT IN CODE ===')
review_not_code = review_tools - code_tools
for tool in sorted(review_not_code):
    print(f'  {tool}')

print(f'\nCount: {len(review_not_code)}')

print('\n=== TOOLS IN PLAN AND REVIEW BUT NOT IN CODE ===')
both_not_code = (plan_tools & review_tools) - code_tools
for tool in sorted(both_not_code):
    print(f'  {tool}')

print(f'\nCount: {len(both_not_code)}')
