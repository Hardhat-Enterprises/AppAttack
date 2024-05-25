import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://stargazers.club',
	integrations: [
		starlight({
			title: 'App-Attack',
			social: {
				github: 'https://github.com/withastro/starlight',
			},
			sidebar: [
				{
					label: 'Penetration Testing Learning Resources',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Installing VirtualBox and Pentest Distro', link: '/guides/pentest/installing-vm' },
						{label: 'Getting Started', link: '/guides/pentest/getting-started'},
						{label: 'Burp Suite', link: '/guides/pentest/burp-suite'},
						{label: 'Practice & Additional Resources', link: '/guides/pentest/practice-additional-resources'}
					]
				},
				{
					label: 'Secure Code Review Learning Resource',
					items: [
						{ label: 'What is Secure Code Review ?', link: '/guides/secure-code-review/what-is-secure-code-review' },
						{ label: 'Learning Resources', link: '/guides/secure-code-review/learning-resources' }
					]				
				},
				{
					label: 'Miscellaneous',
					items: [
						{
							label: 'Miscellaneous', link: '/guides/other-resources/miscellaneous'
						}
					]
				},
				{
					label: 'Tools Installation',
					items: [
						{
							label: 'Snyk Tool', link: '/guides/Tools Installation/Snyk'
						}
					]
				}
			],
		}),
	],
});
