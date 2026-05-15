#!/bin/bash
echo "⚖️ Adding Privacy Policy and Terms pages..."

cat > frontend/src/components/pages/Privacy.tsx << 'EOF'
export default function Privacy() {
  return (
    <div className="min-h-screen bg-[#FFFDF7]">
      <div className="bg-[#1A1A0F] py-14 px-6">
        <div className="max-w-3xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-[3px] uppercase mb-3">Legal</p>
          <h1 className="font-display text-4xl font-bold text-[#FFFDF7]">Privacy Policy</h1>
          <p className="text-[#FFFDF7]/40 text-sm mt-2">Last updated: 15 May 2026</p>
        </div>
      </div>
      <div className="max-w-3xl mx-auto px-6 py-14 space-y-10 text-black/65 text-sm leading-relaxed">

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">1. Who we are</h2>
          <p>FirstStep is a free career platform built for South African youth. We are based in Cape Town, South Africa. You can contact us at <a href="mailto:momozamihlali@gmail.com" className="text-[#C47D0A] underline">momozamihlali@gmail.com</a>.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">2. What information we collect</h2>
          <p className="mb-3">When you register and use FirstStep we collect:</p>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>Your name, email address, and password (stored securely, password hashed)</li>
            <li>Province and city you provide</li>
            <li>CV information you enter — education, skills, work experience, references</li>
            <li>Job alert preferences (sector and province)</li>
            <li>Messages you send to the AI Coach</li>
            <li>Applications you submit through the platform</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">3. How we use your information</h2>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>To provide and improve the FirstStep service</li>
            <li>To send you daily job alert emails if you opt in</li>
            <li>To send a welcome email when you register</li>
            <li>To generate your CV PDF on request</li>
            <li>We do not sell your data to third parties</li>
            <li>We do not use your data for advertising</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">4. Third-party services</h2>
          <p className="mb-3">FirstStep uses the following third-party services:</p>
          <ul className="list-disc pl-5 space-y-1.5">
            <li><strong className="text-black/80">Adzuna</strong> — job listings data. Your search queries are sent to Adzuna's API.</li>
            <li><strong className="text-black/80">Groq</strong> — AI Coach responses. Your messages are processed by Groq's LLaMA model.</li>
            <li><strong className="text-black/80">Resend</strong> — email delivery for welcome and alert emails.</li>
            <li><strong className="text-black/80">Render</strong> — hosting and database. Your data is stored on Render's servers in the US (Oregon).</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">5. Data retention</h2>
          <p>We keep your account data for as long as your account is active. You can request deletion of your account and all associated data by emailing us. We will action this within 7 business days.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">6. Your rights</h2>
          <p className="mb-3">Under South Africa's Protection of Personal Information Act (POPIA) you have the right to:</p>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>Access the personal information we hold about you</li>
            <li>Request correction of inaccurate information</li>
            <li>Request deletion of your information</li>
            <li>Object to the processing of your information</li>
          </ul>
          <p className="mt-3">To exercise any of these rights email us at <a href="mailto:momozamihlali@gmail.com" className="text-[#C47D0A] underline">momozamihlali@gmail.com</a>.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">7. Cookies</h2>
          <p>FirstStep uses localStorage to keep you logged in and remember your preferences. We do not use tracking cookies or advertising cookies.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">8. Changes to this policy</h2>
          <p>We may update this policy from time to time. We will notify registered users by email of any significant changes.</p>
        </section>

      </div>
    </div>
  )
}
EOF

cat > frontend/src/components/pages/Terms.tsx << 'EOF'
import { Link } from 'react-router-dom'
export default function Terms() {
  return (
    <div className="min-h-screen bg-[#FFFDF7]">
      <div className="bg-[#1A1A0F] py-14 px-6">
        <div className="max-w-3xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-[3px] uppercase mb-3">Legal</p>
          <h1 className="font-display text-4xl font-bold text-[#FFFDF7]">Terms of Use</h1>
          <p className="text-[#FFFDF7]/40 text-sm mt-2">Last updated: 15 May 2026</p>
        </div>
      </div>
      <div className="max-w-3xl mx-auto px-6 py-14 space-y-10 text-black/65 text-sm leading-relaxed">

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">1. Acceptance</h2>
          <p>By using FirstStep you agree to these terms. If you do not agree, please do not use the platform. These terms are governed by South African law.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">2. The service</h2>
          <p className="mb-3">FirstStep provides:</p>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>A free CV builder with PDF download</li>
            <li>Live SA job and learnership listings aggregated from third-party sources</li>
            <li>An AI-powered career coaching chatbot</li>
            <li>Information about government employment programmes</li>
            <li>Email job alerts (opt-in only)</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">3. Job listings disclaimer</h2>
          <p className="mb-3">Job listings on FirstStep are sourced from Adzuna and other third parties. We do not verify every listing. <strong className="text-black/80">Always verify opportunities directly with the employer before paying any money or sharing sensitive personal information.</strong></p>
          <p>FirstStep will never ask you to pay to apply for a job or learnership. If someone claiming to be from FirstStep asks you for money, it is a scam.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">4. AI Coach</h2>
          <p>The AI Coach is powered by a large language model and provides general career guidance. It is not a qualified career counsellor, legal advisor, or recruitment professional. Do not rely solely on AI Coach advice for important career decisions.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">5. Your account</h2>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>You must be 13 or older to use FirstStep</li>
            <li>You are responsible for keeping your password secure</li>
            <li>You may not create accounts for other people without their permission</li>
            <li>You may not use FirstStep for any unlawful purpose</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">6. Your content</h2>
          <p>The CV information you enter remains yours. By using FirstStep you give us permission to store and process it to provide the service (generating your PDF, sending alerts, etc.). We do not claim ownership of your CV content.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">7. Limitation of liability</h2>
          <p>FirstStep is provided free of charge and "as is". We are not liable for any losses arising from your use of the platform, including missed job opportunities, incorrect information in listings, or AI Coach advice.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">8. Termination</h2>
          <p>We may suspend or terminate accounts that violate these terms. You may delete your account at any time by contacting us.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">9. Contact</h2>
          <p>For any questions about these terms email <a href="mailto:momozamihlali@gmail.com" className="text-[#C47D0A] underline">momozamihlali@gmail.com</a> or use the <Link to="/contact" className="text-[#C47D0A] underline">contact form</Link>.</p>
        </section>

      </div>
    </div>
  )
}
EOF

echo "✅ Legal pages done!"
