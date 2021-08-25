---
categories: ['blog']
title: A retrospective on Multi

---

Perhaps my favorite phase of any project is when I get to call it done.
[Multi](https://github.com/kofigumbs/multi) has come a long way since [its initial announcement](/blog/multi).
It was neat to have built a tool that (1) had become part of my daily workflow and (2) have so many interesting opportunities for extension.
Neither of those points are true for me today, so I decided to [make Multi free](https://github.com/kofigumbs/multi/commit/14f2d1b5524a8477f203d8e1cb4b6100ea35a5f2) for new users.

## Selling

Multi earned around $1500.
In total, that's a pretty impressive number to me: coming out to ~$100/month.
The catch is that only 1/3 of those earnings came from sales.
The rest came from an API extension I made to support another developer's use case--contract work, essentially.
I don't have issues with contract work generally, but I don't have capacity for any right now.
Deducting that one-off, Multi maybe sells one or two licenses in a normal month, and that's not enough to offset the support effort.
I always suspected Multi would sell a bit more if I put in any amount of effort towards marketing, but I never gathered the enthusiasm for that.
[Marketing is the opposite of hacking.](https://macwright.com/2021/07/24/hacking-is-the-opposite-of-marketing.html)

## Not proficient and not excited

For the most part, I've been able to resolve user issues as they come up.
There are a couple bugs though that I can't figure out.
I've spent several hours looking into these issues, and ultimately those sessions leave me intimately aware of my unfamiliarity with macOS development.
Reflecting on those experiences, I realized that I need at least one of the following conditions in order to stay motivated:

 1. I am in a professional setting: "I am being paid to solve this bug."
 2. I am aiming for proficiency: "This bug is something I need to understand."
 3. I am genuinely interested in the problem space: "What a fun bug!"

The previous section explains how Multi doesn't fall under motivation #1.
Since I no longer use Multi myself and am not aiming for proficiency in AppKit, Multi work has never fit into #2 and has gradually slipped out of #3.
Thinking through that list helped me realize that I'm ready to move on to other projects.

---

Multi 2.1.4 is the first version that removes the license key checks.
I will continue supporting Multi 2.1.3 installations until their license keys expire.
I also plan to clean up the GitHub issues to make the project more amenable to outside contributions.
If Multi stirs any of your core motivations, I hope you [stop by](https://github.com/kofigumbs/multi)!
