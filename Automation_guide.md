The Automation  tool can be used to run any industry standard tool on the specified directory. 

**FLOW**

1. Run the command tools2.sh.
2. The script will download all necessary files.
3. When prompted, indicate whether you want to update by typing y (yes) or n (no).
4. Specify the tool you want to run when asked.
5. Provide the path to the folder containing the code that needs to be tested.
6. The generated results will be stored in a text file located at /home/kali.

**Available Tools**

1. osv-scanner: a tool that scans your project dependencies for known vulnerabilities using the Open Source Vulnerability database.
2. Snyk: A tool that scans your projects for vulnerabilities and provides fixes to enhance security in code, dependencies, containers, and infrastructure as code.
3. Brakeman:  It detect security vulnerabilities, providing detailed reports to help developers fix issues before deployment.
4. Nmap : It is a network scanning tool used for discovering hosts, services, and vulnerabilities on a network.
5. Nikto : It is a web server scanner that checks for vulnerabilities, outdated software, and misconfigurations.
6. Owasp zap : Its a web application security scanner used to find vulnerabilities in web applications during development and testing.
